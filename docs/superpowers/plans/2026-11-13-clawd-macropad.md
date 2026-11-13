# Clawd Macropad Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port Clawdmeter to an ESP32-S3 SuperMini with a 1.3" ST7789, add
6 keys, a rotary encoder, a piezo and an on-device 25/5 focus timer, and
print a case for it.

**Architecture:** The firmware lives in a private Clawdmeter fork as a new
board, `s3_supermini_st7789`. New logic goes in Arduino-free modules covered
by Clawdmeter's `native` unit tests. Thin board and LVGL files wire them in.
K1, K2, Enter, Esc, volume and mute go through Clawdmeter's existing
`button_run_press()` path. The case is parametric OpenSCAD in this repo.

**Tech Stack:** PlatformIO (pioarduino espressif32), Arduino-ESP32,
Arduino_GFX, LVGL, NimBLE-Arduino, Unity (native tests); OpenSCAD and
`tools/validate_stl.py` for the case.

**Spec:** `docs/superpowers/specs/2026-11-13-clawd-macropad-design.md`

## Global Constraints

- The Clawdmeter fork is a **private** repo (it has no license and includes
  proprietary fonts and art). No Clawdmeter code or art goes into this repo.
- Pin map, exactly as in spec section 3.1: LCD SCK 13, MOSI 12, DC 11, RST 10,
  BLK 9; K1-K6 = 1, 2, 4, 5, 6, 7; ENC A 8, B 14, SW 15; piezo 16. GPIO 3, 43
  and 44 stay unused.
- LCD CS is `GFX_NOT_DEFINED`. 240x240, `ips=true`, offsets copied from
  `waveshare_lcd_154/display.cpp`.
- Flash 4 MB with `huge_app.csv`.
- Focus 25 min (1 500 000 ms), break 5 min (300 000 ms).
- Key map:

  | Input | Action |
  |---|---|
  | K1 | Space, held (`BTN_ACT_SPACE`) |
  | K2 | Shift+Tab |
  | K3 | Enter |
  | K4 | Esc |
  | K5 | Timer start/pause; long press resets |
  | K6 | Next screen |
  | Encoder turn | `HID_CONSUMER_VOL_UP` / `HID_CONSUMER_VOL_DOWN` |
  | Encoder press | `HID_CONSUMER_MUTE` |

- Rule 1 in `CLAUDE.md` applies: any hardware value not in the spec is
  measured on the real part and recorded, never guessed.

## Review Focus

1. A key pressed while the screen is asleep should only wake it. K5 must not
   start the timer on that press. Test: `test_dispatch_wake_press_swallowed`
   (Task 4).
2. A key pressed while a Clawd attention alert shows should dismiss the alert
   and do nothing else, matching Clawdmeter's touchless rule. Test:
   `test_dispatch_clawd_alert_dismissed_first` (Task 4).
3. A timer-end alert and a Clawd alert at the same time: the first press
   clears the timer alert only. Test:
   `test_dispatch_timer_alert_takes_first_press` (Task 4).
4. The timer must survive the `millis()` wrap after about 49.7 days. Test:
   `test_focus_survives_millis_wrap` (Task 2).
5. Encoder contact bounce must not produce reverse steps. Invalid quadrature
   transitions count as 0. Test: `test_quad_rejects_invalid_transitions`
   (Task 3).

---

### Task 0: Private fork and measurements (human)

**Files:**
- Create: `clawd_macropad/measurements.md` (this repo)

- [ ] **Step 1:** Create a **private** GitHub repo `clawdmeter-macropad`.
  Push Clawdmeter's `main` to it, then create branch `macropad`.
- [ ] **Step 2:** Connect the SuperMini with esptool and record the lines it
  prints for chip, flash size and embedded PSRAM in `measurements.md`.
  Clawdmeter's `platformio.ini` quotes esptool printing "Embedded PSRAM 8MB
  (AP_3v3)" for another board. Which esptool command prints that line is
  unverified, so try `flash_id` first. Expected: 4 MB flash and 2 MB PSRAM
  (per CircuitPython's board files). If the output differs, stop and update
  spec 3.1.
- [ ] **Step 3:** Record in `measurements.md`, in mm, with calipers:
  - SuperMini L/W/thickness and USB-C centre offset
  - ST7789 module PCB L/W, the active-area offset from the PCB edges, and its
    header position
  - EC11 bushing diameter, bushing thread length, body L/W/H, and pin row
    position
  - Piezo module L/W/H and mounting hole positions
  - DSA keycap height on a seated switch
  - Silkscreen check: SuperMini edge pins match spec 3.1 (yes/no)
- [ ] **Step 4:** Commit `measurements.md` to this repo.

### Task 1: Board port boots and shows the meters

**Files (fork):**
- Create: `firmware/src/boards/s3_supermini_st7789/` with `board.h`,
  `board_init.cpp`, `caps.cpp`, `display.cpp`, `input.cpp`, `power.cpp`,
  `imu.cpp`, `touch.cpp`, `sound.cpp`, copied from `waveshare_lcd_154/` and
  then edited
- Modify: `firmware/platformio.ini` to add env `[env:s3_supermini_st7789]`
- Modify: `firmware/test/test_layout/test_main.cpp` to add 240x240 to
  `PANELS` if it is not already there

**Interfaces:**
- Produces: `board.h` macros `LCD_SCLK 13`, `LCD_MOSI 12`, `LCD_DC 11`,
  `LCD_RST 10`, `LCD_BL 9`, `LCD_CS GFX_NOT_DEFINED`,
  `BTN_BACK_GPIO 1` (K1), `BTN_FWD_GPIO 2` (K2),
  `MP_KEY_GPIOS {4, 5, 6, 7}` (K3-K6), `ENC_A_GPIO 8`, `ENC_B_GPIO 14`,
  `ENC_SW_GPIO 15`, `PIEZO_GPIO 16`, `BOARD_HAS_SECONDARY_BUTTON 1`,
  `BOARD_HAS_MACROPAD 1`, `BOARD_HAS_SOUND 1`, and every other
  `BOARD_HAS_* 0`.
- `caps.cpp`: `has_touch=false`, `has_pwr_button=false`, `button_count=2`.

- [ ] **Step 1:** Write the env. Copy `[env:waveshare_lcd_154]`, then set
  `board_upload.flash_size = 4MB`, `board_upload.maximum_size = 4194304`,
  `board_build.partitions = huge_app.csv`, and a `memory_type` that matches
  the PSRAM type recorded in Task 0. `build_src_filter` excludes `boards/`
  and includes only `boards/s3_supermini_st7789/`.
- [ ] **Step 2:** Edit the board files:
  - `display.cpp`: the bus uses `LCD_CS = GFX_NOT_DEFINED`.
  - `power.cpp`: battery stubs return "no battery".
  - `touch.cpp` and `imu.cpp`: no-ops.
  - `sound.cpp`: stubs (Task 5 fills it in).
- [ ] **Step 3:** Run `pio test -d firmware -e native -f test_layout`.
  Expected: PASS.
- [ ] **Step 4:** Run `pio run -d firmware -e s3_supermini_st7789`.
  Expected: SUCCESS with the app under 3 MB.
- [ ] **Step 5 (hardware):** Flash, open the serial monitor and pair from
  Windows. Expected: boot log, meters drawn the right way up, `Connected`, and
  usage numbers matching the desktop app. K1 sends Space held, K2 sends
  Shift+Tab (check in Notepad).
- [ ] **Step 6:** Commit: `feat: s3_supermini_st7789 board port`.

### Task 2: Focus timer state machine (pure)

**Files (fork):**
- Create: `firmware/src/focus_timer.h`, `firmware/src/focus_timer.cpp`
- Test: `firmware/test/test_focus_timer/test_main.cpp`
- Modify: `firmware/platformio.ini`, native env: add `+<focus_timer.cpp>`

**Interfaces:**
- Produces:
  ```c
  enum FocusPhase { FT_IDLE, FT_FOCUS, FT_FOCUS_DONE, FT_BREAK, FT_BREAK_DONE };
  enum FocusEvent { FT_EV_NONE, FT_EV_FOCUS_ENDED, FT_EV_BREAK_ENDED };
  struct FocusTimer { uint8_t phase; bool paused; uint32_t start_ms; uint32_t paused_elapsed_ms; };
  #define FT_FOCUS_MS 1500000UL
  #define FT_BREAK_MS 300000UL
  void       focus_init(FocusTimer* t);
  void       focus_toggle(FocusTimer* t, uint32_t now);   // IDLE->FOCUS; running<->paused
  void       focus_reset(FocusTimer* t);                  // any phase -> IDLE
  FocusEvent focus_tick(FocusTimer* t, uint32_t now);     // FOCUS->FOCUS_DONE, BREAK->BREAK_DONE
  bool       focus_alerting(const FocusTimer* t);         // phase is *_DONE
  void       focus_ack(FocusTimer* t, uint32_t now);      // FOCUS_DONE->BREAK (starts), BREAK_DONE->IDLE
  uint32_t   focus_remaining_ms(const FocusTimer* t, uint32_t now);
  ```

- [ ] **Step 1:** Write the failing tests:
  - `test_focus_starts_on_toggle`: `remaining(t, now0)` is 1500000.
  - `test_focus_pause_freezes_remaining`: toggle at 0, toggle at 60000, then
    `remaining` at 999999 is 1440000.
  - `test_focus_ends_once`: `focus_tick` at 1500000 returns
    `FT_EV_FOCUS_ENDED`, the next tick returns `FT_EV_NONE`, and
    `focus_alerting` is true.
  - `test_ack_starts_break`: after the ack, the phase is `FT_BREAK` and
    `remaining` is 300000.
  - `test_break_end_ack_returns_idle`.
  - `test_reset_from_any_phase`.
  - `test_focus_survives_millis_wrap`: start at `0xFFFFFFFF - 1000`, then
    `remaining` at 1000 is 1500000 - 2001.
- [ ] **Step 2:** Run `pio test -d firmware -e native -f test_focus_timer`.
  Expected: FAIL (undefined symbols).
- [ ] **Step 3:** Implement in `focus_timer.cpp`. All elapsed times use
  unsigned `now - start_ms`.
- [ ] **Step 4:** Run the test again. Expected: PASS.
- [ ] **Step 5:** Commit: `feat: focus timer state machine`.

### Task 3: Input decoding: debounce, long press, quadrature (pure)

**Files (fork):**
- Create: `firmware/src/mp_input.h`, `firmware/src/mp_input.cpp`
- Test: `firmware/test/test_mp_input/test_main.cpp`
- Modify: native env: add `+<mp_input.cpp>`

**Interfaces:**
- Produces:
  ```c
  #define MP_DEBOUNCE_MS 20
  #define MP_LONG_PRESS_MS 800
  struct Debounce { bool stable; bool last_raw; uint32_t changed_ms; };
  bool debounce_step(Debounce* d, bool raw, uint32_t now);   // returns the stable state
  enum PressEvent { PRESS_NONE, PRESS_DOWN, PRESS_SHORT, PRESS_LONG };
  struct PressTracker { bool held; bool long_fired; uint32_t down_ms; };
  PressEvent press_step(PressTracker* p, bool held, uint32_t now);
  // DOWN on press; LONG once at 800 ms while held; SHORT on release only if LONG did not fire
  struct QuadDecoder { uint8_t prev; int8_t accum; uint8_t steps_per_detent; };
  void   quad_init(QuadDecoder* q, uint8_t steps_per_detent, bool a, bool b);
  int8_t quad_step(QuadDecoder* q, bool a, bool b);          // +1 / -1 per detent, else 0
  ```

- [ ] **Step 1:** Write the failing tests:
  - `test_debounce_ignores_19ms_glitch`
  - `test_debounce_accepts_after_20ms`
  - `test_press_short`: down at 0, up at 300 gives `PRESS_SHORT`.
  - `test_press_long_once`: held from 0 gives `PRESS_LONG` at 800, nothing at
    900, and `PRESS_NONE` on release.
  - `test_quad_cw_one_detent`: with `steps_per_detent=4`, the Gray sequence
    00→01→11→10→00 returns +1 exactly once.
  - `test_quad_ccw_one_detent`: the reverse sequence returns -1 once.
  - `test_quad_rejects_invalid_transitions`: 00→11 and 01→10 return 0 and do
    not change `accum`.
- [ ] **Step 2:** Run `pio test -d firmware -e native -f test_mp_input`.
  Expected: FAIL.
- [ ] **Step 3:** Implement. `quad_step` uses a 16-entry table indexed by
  `(prev<<2)|cur`, with 0 for invalid transitions.
- [ ] **Step 4:** Run the test again. Expected: PASS.
- [ ] **Step 5:** Commit: `feat: macropad input decoding`.

### Task 4: Key dispatch rules (pure)

**Files (fork):**
- Create: `firmware/src/mp_dispatch.h`, `firmware/src/mp_dispatch.cpp`
- Test: `firmware/test/test_mp_dispatch/test_main.cpp`
- Modify: native env: add `+<mp_dispatch.cpp>`

**Interfaces:**
- Consumes: `PressEvent` (Task 3)
- Produces:
  ```c
  enum MpInput  { MP_K3, MP_K4, MP_K5, MP_K6, MP_ENC_SW, MP_ENC_CW, MP_ENC_CCW };
  enum MpAction { MPA_NONE, MPA_WAKE_ONLY, MPA_DISMISS_CLAWD, MPA_ACK_TIMER,
                  MPA_SEND /* send `action` via button_run_press */,
                  MPA_TIMER_TOGGLE, MPA_TIMER_RESET, MPA_NEXT_SCREEN };
  struct MpResult { uint8_t action; int32_t send; };   // send: a button_action.h value
  struct MpContext { bool asleep; bool clawd_alert; bool timer_alert; };
  MpResult mp_dispatch(MpInput in, PressEvent ev, MpContext ctx);
  ```
  Order of precedence: asleep → `MPA_WAKE_ONLY`; timer_alert →
  `MPA_ACK_TIMER`; clawd_alert → `MPA_DISMISS_CLAWD`; otherwise the key map.
  The first three rules apply only to `PRESS_DOWN`. The caller passes each
  encoder step as `MP_ENC_CW`/`MP_ENC_CCW` with `PRESS_DOWN`. K5:
  `PRESS_SHORT` → toggle, `PRESS_LONG` → reset, `PRESS_DOWN` → none. K6:
  `PRESS_SHORT` → next screen. K3 and K4 send on `PRESS_DOWN`.
  - K3: `BTN_ACT_ENTER`
  - K4: `BTN_ACT_ESCAPE`
  - ENC_SW: `0x20000|HID_CONSUMER_MUTE`
  - CW: `0x20000|HID_CONSUMER_VOL_UP`
  - CCW: `0x20000|HID_CONSUMER_VOL_DOWN`

- [ ] **Step 1:** Write the failing tests:
  - `test_dispatch_key_map`: every input above in the idle context.
  - `test_dispatch_wake_press_swallowed`: K5 `PRESS_DOWN` while asleep gives
    `MPA_WAKE_ONLY`.
  - `test_dispatch_clawd_alert_dismissed_first`: K3 down with clawd_alert
    gives `MPA_DISMISS_CLAWD`, not send.
  - `test_dispatch_timer_alert_takes_first_press`: timer_alert and
    clawd_alert both set give `MPA_ACK_TIMER`.
  - `test_dispatch_k5_long_resets_no_toggle`.
- [ ] **Step 2:** Run `pio test -d firmware -e native -f test_mp_dispatch`.
  Expected: FAIL.
- [ ] **Step 3:** Implement the precedence rules in `mp_dispatch()`.
- [ ] **Step 4:** Run the test again. Expected: PASS.
- [ ] **Step 5:** Commit: `feat: macropad dispatch rules`.

### Task 5: Piezo tones (pure patterns + board sound HAL)

**Files (fork):**
- Create: `firmware/src/tone_seq.h`, `firmware/src/tone_seq.cpp`
- Test: `firmware/test/test_tone_seq/test_main.cpp`
- Modify: `firmware/src/boards/s3_supermini_st7789/sound.cpp`; native env:
  add `+<tone_seq.cpp>`

**Interfaces:**
- Produces:
  ```c
  struct ToneStep { uint16_t hz; uint16_t ms; };   // hz 0 = silence
  enum TonePattern { TONE_DING, TONE_TIMER_END };
  const ToneStep* tone_pattern(TonePattern p, uint8_t* count);
  struct ToneSeq { const ToneStep* steps; uint8_t count; uint8_t i; uint32_t step_start; bool active; };
  void     tone_seq_start(ToneSeq* s, TonePattern p, uint32_t now);
  int32_t  tone_seq_tick(ToneSeq* s, uint32_t now);  // -1 = unchanged; else the hz to output now (0 = off)
  ```
  Pattern values (design choice): `TONE_DING` = {2000 Hz 80 ms, 0 40, 2500 80};
  `TONE_TIMER_END` = {1500 200, 0 100, 1500 200, 0 100, 2000 400}.
- `sound.cpp`: `sound_hal_chime()` starts `TONE_DING`. New
  `void sound_hal_timer_end(void)` (declared in a board-local header
  `piezo.h`) starts `TONE_TIMER_END`. `sound_hal_tick()` applies
  `tone_seq_tick` through the core's LEDC tone call and never blocks. Look up
  that call's exact signature in the installed core's `esp32-hal-ledc.h`
  before writing it. The pin-based `ledcAttach()` already used in
  `waveshare_lcd_154/display.cpp` means this is the pin-based LEDC API.

- [ ] **Step 1:** Write the failing tests:
  - `test_patterns_distinct_and_nonempty`
  - `test_seq_walks_steps_on_time`: for `TONE_DING`, the tick at 0 gives 2000,
    at 80 gives 0, at 120 gives 2500, at 200 gives 0 and inactive.
  - `test_seq_unchanged_returns_minus1`
- [ ] **Step 2:** Run `pio test -d firmware -e native -f test_tone_seq`.
  Expected: FAIL.
- [ ] **Step 3:** Implement `tone_seq.cpp`, then `sound.cpp`.
- [ ] **Step 4:** Run the test again. Expected: PASS. Then run
  `pio run -e s3_supermini_st7789`. Expected: SUCCESS.
- [ ] **Step 5 (hardware):** Run the serial command `chime`. Expected: the
  DING pattern is audible.
- [ ] **Step 6:** Commit: `feat: piezo tone sequencer`.

### Task 6: Focus timer screen and alert (LVGL)

**Files (fork):**
- Create: `firmware/src/focus_ui.h`, `firmware/src/focus_ui.cpp`
- Modify: `firmware/src/ui.cpp` to call `focus_ui_init(scr)` at the end of
  `ui_init()`

**Interfaces:**
- Consumes: `FocusTimer`, `focus_remaining_ms`, `focus_alerting` (Task 2)
- Produces:
  ```c
  void focus_ui_init(lv_obj_t* scr);       // full-screen container, hidden, on top
  void focus_ui_set_visible(bool on);
  bool focus_ui_visible(void);
  void focus_ui_update(const FocusTimer* t, uint32_t now);   // call each loop; cheap if unchanged
  ```
  Layout from the approved mockup:
  - "FOCUS" (or "BREAK") title at the top, in the accent colour.
  - 160 px arc with a 12 px stroke, green on the track colour.
  - `MM:SS` in mono 32.
  - "of 25:00" (or "of 5:00").
  - "next: break 5:00" in the accent colour, on focus only.
  - Alert: the whole container turns accent colour, black text
    "Focus done / Break 5:00 / press any key" (or "Break done / press any
    key"), flashing at 1 Hz.
  - Colours come from `theme_palette.h`, not hard-coded.

- [ ] **Step 1:** Implement. Redraw only when the displayed second, the phase
  or the visibility changes.
- [ ] **Step 2:** Run `pio run -e s3_supermini_st7789`. Expected: SUCCESS.
- [ ] **Step 3:** Commit: `feat: focus timer screen`. Hardware check happens
  in Task 7.

### Task 7: Wire the macropad into the main loop

**Files (fork):**
- Create: `firmware/src/hal/macropad_hal.h`; implementation in
  `boards/s3_supermini_st7789/input.cpp`
- Modify: `firmware/src/main.cpp`, adding a `#if BOARD_HAS_MACROPAD` block
  in `loop()` after the PWR handling, and an init call in `setup()`

**Interfaces:**
- Consumes: Tasks 2-6.
- Produces:
  ```c
  void macropad_hal_init(void);                 // INPUT_PULLUP on K3-K6, ENC A/B/SW
  bool macropad_hal_key_held(uint8_t idx);      // idx 0..3 = K3..K6
  bool macropad_hal_enc_a(void);
  bool macropad_hal_enc_b(void);
  bool macropad_hal_enc_sw(void);
  ```
- Glue per loop:
  1. Debounce, then `press_step` for K3-K6 and ENC_SW; `quad_step` for the
     encoder.
  2. Build `MpContext{idle_is_asleep(), <Clawd alert active>, focus_alerting(&ft)}`
     and call `mp_dispatch`.
  3. Act on the result:
     - `WAKE_ONLY` → `idle_consume_wake_press()`
     - `DISMISS_CLAWD` → `director_button(true)`
     - `ACK_TIMER` → `focus_ack`
     - `SEND` → `button_run_press(BTN_SLOT_PWR, &run, send, false)`, the
       existing tap path with no held keys
     - `TIMER_TOGGLE` / `TIMER_RESET` → focus functions
     - `NEXT_SCREEN` → `focus_ui_set_visible(!focus_ui_visible())`
  4. Then `if (focus_tick(&ft, millis()) != FT_EV_NONE) sound_hal_timer_end();`
     and `focus_ui_update(&ft, millis())`.
  5. Read `steps_per_detent` from a board constant `ENC_STEPS_PER_DETENT`.
     Its value comes from Step 3 below.
  6. Before using "Clawd alert active", find the director's alert-active
     query in `clawd_director.h` and use it. If none exists, add a
     getter there.

- [ ] **Step 1:** Implement the HAL and glue.
- [ ] **Step 2:** Run `pio test -d firmware -e native`. Expected: all suites
  PASS. Then `pio run -e s3_supermini_st7789`. Expected: SUCCESS.
- [ ] **Step 3 (hardware):** Turn the encoder one detent at a time with
  serial logging of raw A/B transitions. Record transitions per detent in
  `measurements.md` and set `ENC_STEPS_PER_DETENT` to it.
- [ ] **Step 4 (hardware):** Run through spec section 6:
  - K3 sends Enter, K4 Esc; encoder turns change Windows volume one step per
    detent; encoder press mutes.
  - K6 switches screens; K5 starts and pauses, long press resets.
  - A full cycle with `FT_FOCUS_MS` temporarily set to 60000: alert, beep,
    any key starts the break, break end, alert, back to idle.
  - Restore 1500000 and confirm by grep.
- [ ] **Step 5:** Commit: `feat: macropad keys, encoder and focus timer`.

### Task 8: Case test coupon (this repo)

**Files:**
- Create: `clawd_macropad/clawd_macropad.scad`, `clawd_macropad/stl/coupon.stl`

**Interfaces:**
- Consumes: `clawd_macropad/measurements.md` (Task 0)
- Produces: in the `.scad`, `part = "coupon" | "top" | "bottom"`, every
  dimension a named top-level parameter, and each measured value commented
  `// measured: measurements.md`.

- [ ] **Step 1:** Model the coupon: a 1.5 mm plate with one 14.0 x 14.0 mm
  switch hole, the EC11 bushing hole at the measured diameter +0.3 mm, and
  the display window at the measured active area + its offset.
- [ ] **Step 2:** Run `.claude/skills/openscad/tools/validate.sh` on the
  file, export the STL, then run
  `python3 tools/validate_stl.py clawd_macropad/stl/coupon.stl`.
  Expected: no errors.
- [ ] **Step 3:** Render multi-angle previews with `xvfb-run -a` and look at
  each one.
- [ ] **Step 4 (hardware):** Print the coupon. A switch clicks in and holds,
  the encoder nut tightens, and the window lines up with the active area.
  Record any fit adjustments as parameters.
- [ ] **Step 5:** Commit: `feat: clawd macropad case coupon`.

### Task 9: Full case (this repo)

**Files:**
- Modify: `clawd_macropad/clawd_macropad.scad`
- Create: `clawd_macropad/stl/top.stl`, `clawd_macropad/stl/bottom.stl`

- [ ] **Step 1:** Model the case to the approved mockup:
  - Flat key deck with a 3x2 grid at 19.05 mm pitch, back row K1-K3, front
    row K4-K6.
  - Rear wedge with the screen tilted toward the user.
  - Encoder top-right.
  - Bottom tray holding the SuperMini with a USB-C opening at the measured
    offset.
  - Piezo pocket with sound holes.
  - Cable room for the 15 wires.
  - Fillets and chamfers like the nozzle-cam parts.
- [ ] **Step 2:** Export both parts and run `tools/validate_stl.py` on each.
  Expected: no errors.
- [ ] **Step 3:** Render previews and inspect them.
- [ ] **Step 4 (hardware):** Print, assemble, and run Task 7 Step 4 again in
  the case.
- [ ] **Step 5:** Commit: `feat: clawd macropad case`.
