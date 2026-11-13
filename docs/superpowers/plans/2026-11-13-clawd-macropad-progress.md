# SDD ledger — plan: docs/superpowers/plans/2026-11-13-clawd-macropad.md
Code repo: local clone of Clawdmeter, branch `macropad` (private fork not yet created by user). Baseline: pio test -e native → 127/127 passed.
Pre-flight:
- T3→T4: PressEvent {PRESS_NONE, PRESS_DOWN, PRESS_SHORT, PRESS_LONG} produced by T3, consumed by T4 — consistent.
- T2→T6/T7: FocusTimer API — consistent.
- T5→T7: sound_hal_timer_end() declared in board-local piezo.h — consistent.
- T0→T1: memory_type depends on Task 0 esptool output. Ruling: use quad-PSRAM setting per CircuitPython mpconfigboard.mk (PSRAM_MODE=qio, 2MB) until hardware confirms — cost if wrong: boot fail/black screen, fix by changing memory_type.
Task 0: Ruling: deferred — human task (private repo + caliper measurements); code kept in local clone; Tasks 8-9 blocked on it — cost: none until push.
Execution order: Ruling: run pure Tasks 2,3,4,5 before Task 1 — they share no files with Task 1; hardware steps of all tasks recorded as pending — cost: none.
Task 2: Ruling: added tests test_ack_ignored_when_not_alerting and test_toggle_ignored_while_alerting; toggle does nothing while an alert shows (dispatcher acks instead) — spec: alert holds until any key — cost if wrong: K5 cannot pause during alert (it acks instead).
Task 2: complete (commits f8df834..00d3c7e, tests: pio test -d firmware -e native → ================ 136 test cases: 136 succeeded in 00:00:10.538 ================)
Task 3: Ruling: added test_quad_bounce_does_not_step; invalid quadrature transition resyncs prev to the new state (accum unchanged) — avoids a stale prev producing a wrong step next — cost if wrong: one lost detent after electrical noise.
Task 3: complete (commits 00d3c7e..df4228b, tests: pio test -d firmware -e native → ================ 144 test cases: 144 succeeded in 00:00:11.070 ================)
Task 4: Ruling: mp_dispatch gains a 4th param bool* swallowed (per-input state) — without it a wake/alert DOWN on K5/K6 would still fire toggle/next-screen on release (Review Focus 1) — cost if wrong: none functional; T7 glue must keep one bool per MpInput.
Task 4: complete (commits df4228b..ca003f1, tests: pio test -d firmware -e native → ================ 150 test cases: 150 succeeded in 00:00:11.903 ================)
Task 5: Ruling: split — pure tone_seq done now (commit c626e84); board sound.cpp waits for Task 1's board folder; added tests test_seq_restart_interrupts, test_seq_late_tick_skips_ahead and ToneSeq.started field (needed so the first tick reports the first step) — cost if wrong: none.
Task 1: BLOCKED at Step 4 (pio run): pioarduino penv needs platformio-core from a GitHub archive URL; proxy returns 403 for github.com/archive + codeload. Installing from a git clone was denied by the permission classifier. Step 3 (test_layout) PASSED 8/8. Board files committed as WIP 46b3071. Ruling: memory_type=qio_qspi (CircuitPython PSRAM_MODE=qio) — unverified that this value exists in the core until the build runs.
Repo moved: work continues in /home/user/clawdmeter_esp (private navazdeen/clawdmeter_esp), branch macropad = e5b1492; upstream imported as one snapshot commit 350ee26 (shallow clone could not be pushed). Commits re-hashed by trailer amend.
Task 1: build recipe in this container: PLATFORMIO_OFFLINE=1 pio run -e s3_supermini_st7789 (penv deps installed from pioarduino/platformio-core v6.1.19 git tag with user approval; proxy CA appended to penv certifi bundle because penv_setup.py:871 overrides REQUESTS_CA_BUNDLE). Build SUCCESS: RAM 34.8%, Flash 1748662/3145728. esptool penv install fails (upload only) — flashing happens on user's PC.
Task 1: Step 5 (hardware flash/pair) PENDING — needs the board.
Task 1: complete (commits 8353ab4..e5b1492, tests: pio test -d firmware -e native → ================ 155 test cases: 155 succeeded in 00:00:13.999 ================)
Task 5: board sound.cpp uses ledcAttach + ledcWriteTone(pin,hz) (verified in installed core esp32-hal-ledc.h:89,132); build SUCCESS. Step 5 (audible chime) PENDING hardware.
Task 5: complete (commits acf53d1..6add4d9, tests: pio test -d firmware -e native → ================ 155 test cases: 155 succeeded in 00:00:13.167 ================)
Task 6: Ruling: focus_ui_init is called from main.cpp's BOARD_HAS_MACROPAD block (Task 7), not ui.cpp — keeps shared UI untouched for other boards — cost if wrong: none.
Task 6: Ruling: parent is lv_layer_top() and the root is moved to the foreground on show — covers Clawd sprites (face.cpp also uses layer_top) — cost if wrong: sprites could draw over the timer.
Task 6: Ruling: idle state (not in mockup) shows FOCUS / 25:00 / "of 25:00" / "K5 to start"; paused shows "paused" as subtitle — cost if wrong: cosmetic.
Task 6: LVGL resolved to 9.6.0 (lib_deps ^9.2.0); arc/hidden/clickable APIs checked in include/lvgl headers. Build SUCCESS. Hardware look PENDING (Task 7).
Task 6: complete (commits 6add4d9..828a083, tests: pio test -d firmware -e native → ================ 155 test cases: 155 succeeded in 00:00:13.025 ================)
Task 7: Ruling: BOARD_HAS_MACROPAD is a -D build flag in the env, not a board.h macro — main.cpp never includes board.h (shared code reads flags/caps) — cost if wrong: none.
Task 7: Ruling: sound_hal_timer_end() declared in hal/macropad_hal.h (piezo.h removed) — main.cpp needs it and must not include board-local headers — cost if wrong: none.
Task 7: Ruling: asleep comes from idle_consume_wake_press() on PRESS_DOWN (it also does idle bookkeeping per idle.h), not idle_is_asleep() — cost if wrong: none.
Task 7: Ruling: on a timer phase end the focus screen auto-shows and idle_note_activity() lights the panel (idle.cpp:46-53) — spec: screen flashes until a key — cost if wrong: alert would be hidden behind the meters.
Task 7: Added director_attention_active() getter (clawd_director.cpp, returns attention_on). Builds: s3_supermini_st7789 SUCCESS, waveshare_lcd_154 SUCCESS (regression). Steps 3-4 (encoder transitions/detent, full hardware run) PENDING hardware.
Task 7: complete (commits 828a083..5879424, tests: pio test -d firmware -e native → ================ 155 test cases: 155 succeeded in 00:00:10.246 ================)
Tasks 8-9: Ruling: not started — need Task 0 caliper measurements (Rule 1: no guessed dimensions) — cost: case work waits for parts.
Final review: fresh reviewer (opus) — verdict merge with fixes; 0 Critical, 4 Important, 7 Minor.
Final: Ruling: re-graded Minor #6 (K5 toggles an invisible timer) to Important — a person presses again and pauses it — cost if wrong: none.
Final: fixed I1 K1/K2 ignore timer alert — test_stock_key_acks_timer_alert_first RED→GREEN, suite 158/158
Final: fixed I3 Clawd alert hidden under focus screen — test_yield_fires_once_per_clawd_alert, test_yield_waits_for_timer_ack RED→GREEN, suite 158/158
Final: Ruling: I2 (face over focus screen) fixed by parenting on lv_layer_sys() + director_button(false) at phase end — LVGL-only, no native test possible; verified by build — cost if wrong: face may still overlap; hardware check.
Final: Ruling: I4 (encoder aliasing) fixed by CHANGE ISR on A/B with portMUX; ARDUINO_ISR_FLAG is 0 (esp32-hal.h:48-54, CONFIG_ARDUINO_ISR_IRAM unset) so flash-resident ISR is safe — no native test possible; verified by build — cost if wrong: missed/aliased detents; hardware fast-spin check.
Final: fixed M6(re-graded) K5 shows the timer screen — glue only, build-verified.
Final: minor (deferred): #5 quad resync leaves accum out of phase after an invalid transition.
Final: minor (deferred): #7 a Clawd ding cuts off the timer-end tone (shared ToneSeq).
Final: minor (deferred): #8 screen never sleeps on this USB-powered board, so the wake-press rule is unreachable on hardware.
Final: minor (deferred): #9 focus screen colours not repainted on a theme change while idle/paused.
Final: minor (deferred): #10 focus_ui.cpp compiles into every env using LVGL 9.6 setters; sim and classic-ESP32 envs not built.
Final: minor (deferred): #11 includes mid-file in main.cpp; commit titled "wip ... (not yet built)" though it builds.
