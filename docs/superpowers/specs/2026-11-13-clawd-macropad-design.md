# Clawd Macropad: design spec

Date: 2026-11-13
Status: approved in brainstorming, awaiting written-spec review

## 1. Goal

A desk device on an ESP32-S3 SuperMini with a 1.3" ST7789 screen, 6 keys, a
rotary encoder and a passive piezo. It shows Claude Code usage limits and the
time, runs a 25/5 focus timer with sound, and sends Claude Code shortcuts and
system volume to a Windows office laptop over Bluetooth LE.

Success by end of weekend:

1. The device pairs with the Windows laptop and shows live session and weekly
   usage from the stock Clawdmeter desktop app.
2. All 6 keys and the encoder send their mapped actions to the laptop.
3. The focus timer runs 25 min focus then 5 min break, and beeps at the end
   of each phase.
4. The parts sit in a printed case that passed `tools/validate_stl.py`.

## 2. Decisions and their sources

| Decision | Source read this session |
|---|---|
| Base firmware on Clawdmeter. It already has BLE usage meters, a clock, HID keyboard keys and media (consumer) keys. | Clawdmeter `README.md`, `docs/protocol.md` |
| Keep the Clawdmeter fork **private**. The repo has no license and bundles Anthropic's proprietary fonts and the Clawd art. Its code does not go into this repo. | Clawdmeter `README.md`, "Licensing gray area warning" |
| Start the port from `waveshare_lcd_154` (240x240 ST7789 over 4-wire SPI, Arduino_GFX). | Clawdmeter `docs/porting/adding-a-board.md`, `boards/waveshare_lcd_154/board.h`, `display.cpp` |
| Screen without a CS pin: pass `GFX_NOT_DEFINED` as CS. Arduino_GFX's ST7789 driver forces SPI mode 3 on ESP32. | Arduino_GFX `src/display/Arduino_ST7789.cpp:22`, `src/databus/Arduino_ESP32SPI.cpp:194`; ShillehTek 1.3" ST7789 manual |
| 4 MB flash: use `huge_app.csv`. Firmware is about 1.65 MB, which overflows the stock 4 MB layout. OTA is dropped. | Clawdmeter `platformio.ini`, `esp32_2432s028r` env comment |
| SuperMini memory: 4 MB flash and 2 MB quad PSRAM | CircuitPython `boards/generic_esp32s3_supermini/mpconfigboard.mk` |
| `has_touch = false`. Keys handle alert dismissal. | Clawdmeter `docs/porting/capability-flags.md` |
| Usage and clock come from the stock Windows app (the `t` field) | `docs/protocol.md`, `src/payload.cpp:54` |
| No pins on GPIO43. The eFuse `UART_PRINT_CONTROL` defaults to 0 = "Enable" (ROM boot messages on), and GPIO43 is UART0 TX. | ESP-IDF `components/efuse/esp32s3/esp_efuse_table.csv:173`; CircuitPython `mpconfigboard.h` (TX = GPIO43) |
| Clawdmeter has no focus timer. A grep for pomodoro, focus timer and countdown matched only pace and power code. | grep of Clawdmeter `firmware/src` |
| Spotify now-playing deferred. Since Feb 2026, Development Mode apps need the app owner to have Premium, and the user has a free account. | Spotify Feb 2026 migration guide, read through search-result summaries (direct fetch blocked) |
| Meetings deferred. Workspace admin has disabled the secret iCal address. | User checked Google Calendar web settings |

## 3. Hardware

### 3.1 Pin map (ESP32-S3 SuperMini)

Edge-header pins, per CircuitPython `pins.c`: left side 43, 44, 1-7; right
side 8-13, then 5V, GND, 3V3. Bottom pads: 14-18, 21, 33-42, 45-47.

| Function | GPIO | Notes |
|---|---|---|
| LCD SCK | 13 | |
| LCD MOSI | 12 | |
| LCD DC | 11 | |
| LCD RST | 10 | |
| LCD BLK (backlight) | 9 | LEDC PWM |
| K1-K6 | 1, 2, 4, 5, 6, 7 | Active-low, internal pull-up |
| ENC A | 8 | Internal pull-up |
| ENC B | 14 | Bottom pad |
| ENC SW | 15 | Bottom pad |
| Piezo | 16 | Bottom pad, LEDC PWM |
| Unused | 3, 43, 44 | 3 is a strapping pin; 43 is the boot-log TX pin; 44's boot behaviour is unverified |

ESP32 skill `validate_pinmap.py` run on this final 15-pin map: valid, 0
errors, 0 warnings.

Clones of this board vary. Before wiring, check the silkscreen on the actual
board against this table.

### 3.2 Parts (amazon.in, from search snapshots; check live listings)

- MX-compatible switches, 10 pcs: Gateron KS-9 or Outemu Brown
- Keycaps: 12x blank DSA PBT (MERISHOPP)
- Encoder: CentIoT EC11, 20 mm shaft, with push switch (2 pcs)
- Passive piezo module, listing must say "passive" and "3.3-5V". The ICSTORE
  listing is ambiguous: its title says passive but its bullets describe an
  active module.

## 4. Firmware changes (private Clawdmeter fork)

1. **New board** `s3_supermini_st7789` (folder and PlatformIO env), copied from
   `waveshare_lcd_154`:
   - `LCD_CS` set to `GFX_NOT_DEFINED`.
   - No touch, battery, IMU or IO expander.
   - `huge_app.csv` partition table.
   - The PSRAM build setting must match quad PSRAM. Unverified until esptool
     prints the chip and PSRAM info from the real board.
2. **Input:** 6 keys plus encoder. The protocol only has `k1`-`k3` today.

   | Input | Action |
   |---|---|
   | K1 | Space (held = push-to-talk) |
   | K2 | Shift+Tab |
   | K3 | Enter |
   | K4 | Esc |
   | K5 | Focus timer start/pause; long press resets |
   | K6 | Next screen |
   | Encoder turn | System volume up/down (consumer usages 0xE9/0xEA) |
   | Encoder press | Mute (0xE2) |

   K1-K4 and the encoder use the existing HID action codes. K5, K6 and the
   encoder are new firmware. This mapping is fixed in firmware for v1; it is
   not remappable from the desktop app.
3. **Screens:** the existing meters/clock screen, plus a new focus-timer
   screen with a big countdown and progress ring. K6 cycles between them.
4. **Focus timer:** 25 min focus, then a 5 min break offered automatically.
   At the end of each phase the piezo beeps and the screen flashes until any
   key is pressed. The timer runs on the device and needs no host.
5. **Sound:** implement `sound_hal_init`, `sound_hal_tick`,
   `sound_hal_chime` and `sound_hal_tune` (`src/hal/sound_hal.h`) for a passive
   piezo driven by LEDC PWM on GPIO16. Use distinct tones for the
   Clawdmeter attention ding and the timer end. Playback must not block, as
   the HAL header requires.

## 5. Case (this repo, OpenSCAD)

- Layout: screen at the top (tilted toward the user), encoder top-right, keys
  in a 3x2 grid below.
- Plate: 14 x 14 mm switch cutouts, 1.5 mm plate, 19.05 mm pitch. These come
  from the ai03 wiki and Deskthority posts reproducing the Cherry datasheet;
  the primary Cherry PDF was not reachable.
- Measure every other dimension with calipers before modelling: SuperMini
  outline and USB-C position, display module outline and active-area offset,
  EC11 bushing diameter and body, piezo diameter, keycap height.
- Print a test coupon first: one switch hole, the encoder hole and the
  display window.
- Same workflow as `kobra2neo_nozzle_cam`: parametric `.scad`, STL export,
  `tools/validate_stl.py`, multi-angle previews.

## 6. Testing

- Firmware: `pio test -d firmware -e native -f test_layout` (240x240 is
  Clawdmeter's "small" tuned layout per its porting guide), then
  `pio run -d firmware -e s3_supermini_st7789`.
- On hardware, go through the porting guide's step 6: boot, every key and
  encoder direction, BLE pairing with Windows, usage updating, brightness,
  piezo, and a full 25/5 timer cycle.
- Case: test coupon fit, then `validate_stl.py`, then the full print.

## 7. Out of scope for v1

- Meetings screen. Next step is a 30-minute throwaway test of a personal
  Google OAuth client against the Workspace account.
- Spotify or Amazon Music now-playing and music control.
- Keys remappable from the desktop app.
- Second BLE host (phone). Clawdmeter allows 2 connections, but sends every
  HID report to all subscribed peers (`ble.cpp`).

## 8. Risks and open items

- The office laptop policy may block the unsigned Clawdmeter installer or BLE
  pairing. Check this before the weekend.
- Behaviour of Clawdmeter's large animations with only 2 MB of PSRAM is
  unverified.
- The encoder's resting contact state is unverified. It matters only for pin
  choice, and the chosen pins (8/14/15) have no boot role.
