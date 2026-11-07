#!/usr/bin/env python3
"""Printability validator for STL parts (in print orientation, bed at min Z).

Implements the checks from flowful-ai/cad-skill (SKILL.md "Print-Friendly
Defaults" + design-review.md) and adds a ray-cast wall-thickness measurement
instead of the skill's volume fill-ratio heuristic.

Checks
  watertight / winding / single body
  sits flat on bed (bed contact area)
  wall thickness  (ray cast inward from every face; min 1.2, recommended 2.0)
  min feature     (< 0.8 mm local thickness)
  overhangs       (> 45 deg from vertical, excluding bed faces)
  bridges         (downward horizontal faces above bed; span < 20 mm)

Usage: python3 validate_stl.py part.stl [part2.stl ...] [--json out.json]
"""
import sys, json, argparse
import numpy as np
import trimesh

WALL_MIN, WALL_REC, FEATURE_MIN = 1.2, 2.0, 0.8
OVERHANG_MAX, BRIDGE_MAX = 45.0, 20.0
BED_EPS = 0.05


def thickness(mesh):
    """Local thickness per face: distance along -normal to the opposite surface."""
    c = mesh.triangles_center
    n = mesh.face_normals
    origins = c - n * 1e-3
    locs, idx_ray, idx_tri = mesh.ray.intersects_location(origins, -n, multiple_hits=False)
    t = np.full(len(c), np.inf)
    d = np.linalg.norm(locs - origins[idx_ray], axis=1)
    t[idx_ray] = d
    return t


def regions(mesh, mask):
    """Connected face groups among mask=True faces."""
    faces = np.nonzero(mask)[0]
    if len(faces) == 0:
        return []
    sel = set(faces.tolist())
    adj = [e for e in mesh.face_adjacency if e[0] in sel and e[1] in sel]
    g = trimesh.graph.connected_components(adj, nodes=faces, min_len=1)
    return [np.asarray(x) for x in g]


def analyse(path):
    m = trimesh.load(path, force="mesh")
    zmin = m.bounds[0][2]
    m.apply_translation([0, 0, -zmin])
    r = {"part": path.split("/")[-1].replace(".stl", ""),
         "bbox_mm": [round(float(x), 1) for x in m.extents],
         "volume_mm3": round(float(m.volume), 0),
         "watertight": bool(m.is_watertight),
         "winding_ok": bool(m.is_winding_consistent),
         "bodies": len(m.split(only_watertight=False))}

    n = m.face_normals
    area = m.area_faces
    zc = m.triangles_center[:, 2]
    on_bed = (zc < BED_EPS) & (n[:, 2] < -0.99)
    r["bed_contact_mm2"] = round(float(area[on_bed].sum()), 0)

    # --- thickness ---
    t = thickness(m)
    finite = np.isfinite(t)
    w = t[finite]; a = area[finite]
    thin = finite & (t < WALL_MIN)
    tiny = finite & (t < FEATURE_MIN)
    r["wall_min_mm"] = round(float(w.min()), 2)
    # area-weighted 1st percentile ignores knife-edge slivers on curved tangents
    order = np.argsort(w); cum = np.cumsum(a[order]) / a.sum()
    r["wall_p1_mm"] = round(float(w[order][np.searchsorted(cum, 0.01)]), 2)
    r["thin_area_mm2"] = round(float(area[thin].sum()), 1)
    r["thin_area_pct"] = round(float(area[thin].sum() / area.sum() * 100), 2)
    r["sub_feature_area_mm2"] = round(float(area[tiny].sum()), 1)
    thin_regions = []
    for g in regions(m, thin):
        ga = area[g].sum()
        if ga < 0.5:        # ignore specks (tessellation slivers)
            continue
        ctr = m.triangles_center[g].mean(axis=0)
        thin_regions.append({"area_mm2": round(float(ga), 1),
                             "min_mm": round(float(t[g].min()), 2),
                             "at_mm": [round(float(x), 1) for x in ctr]})
    r["thin_regions"] = sorted(thin_regions, key=lambda x: -x["area_mm2"])[:8]

    # --- overhangs ---
    down = (n[:, 2] < 0) & ~on_bed
    ang_from_vertical = np.degrees(np.arcsin(np.clip(-n[:, 2], 0, 1)))
    over = down & (ang_from_vertical > OVERHANG_MAX + 0.5) & (n[:, 2] > -0.99)
    r["overhang_area_mm2"] = round(float(area[over].sum()), 1)
    r["overhang_pct"] = round(float(area[over].sum() / area.sum() * 100), 2)

    # --- bridges (flat ceilings above bed) ---
    flat_ceiling = (n[:, 2] < -0.99) & ~on_bed
    bridges = []
    for g in regions(m, flat_ceiling):
        if area[g].sum() < 1.0:
            continue
        pts = m.triangles[g].reshape(-1, 3)
        ext = pts.max(0) - pts.min(0)
        span = float(min(ext[0], ext[1]))
        bridges.append({"span_mm": round(span, 1),
                        "area_mm2": round(float(area[g].sum()), 1),
                        "z_mm": round(float(pts[:, 2].mean()), 1)})
    r["bridges"] = sorted(bridges, key=lambda x: -x["span_mm"])[:6]

    # --- verdicts ---
    issues = []
    if not r["watertight"]: issues.append("FAIL not watertight")
    if r["bodies"] != 1:    issues.append(f"FAIL {r['bodies']} separate bodies")
    if r["bed_contact_mm2"] < 20: issues.append("FAIL little/no flat bed contact")
    for tr in r["thin_regions"]:
        lvl = "FAIL" if tr["min_mm"] < FEATURE_MIN and tr["area_mm2"] > 2 else "WARN"
        issues.append(f"{lvl} thin wall {tr['min_mm']} mm over {tr['area_mm2']} mm2 at {tr['at_mm']}")
    for b in r["bridges"]:
        if b["span_mm"] > BRIDGE_MAX:
            issues.append(f"WARN bridge {b['span_mm']} mm (> {BRIDGE_MAX}) at z={b['z_mm']}")
    if r["overhang_area_mm2"] > 5:
        issues.append(f"WARN {r['overhang_area_mm2']} mm2 overhang > {OVERHANG_MAX} deg")
    r["issues"] = issues
    r["verdict"] = "FAIL" if any(i.startswith("FAIL") for i in issues) else \
                   ("WARN" if issues else "PASS")
    return r


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("stl", nargs="+")
    ap.add_argument("--json")
    a = ap.parse_args()
    out = [analyse(p) for p in a.stl]
    for r in out:
        print(f"\n== {r['part']}  [{r['verdict']}]  bbox {r['bbox_mm']} mm, "
              f"wall min {r['wall_min_mm']} / p1 {r['wall_p1_mm']} mm, "
              f"watertight={r['watertight']}, bodies={r['bodies']}")
        for i in r["issues"]:
            print("   ", i)
    if a.json:
        json.dump(out, open(a.json, "w"), indent=1)
