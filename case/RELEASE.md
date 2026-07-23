# Azoteq TPS43 Trackpad Holder — Corne V4 Pro Micro Edition (right half)

A drop-in trackpad mount for the **Corne V4 Pro Micro Edition** (Kea Workshop
PCB). It carries an **Azoteq TPS43** capacitive trackpad (43 × 40 mm, IQS572
chip) and bolts onto the right half using the **existing RP2040 cover screw
holes** — no drilling, no PCB modification. Ships as a single printable part.

---

## Files

| File | What it is |
|------|------------|
| `tps43_holder_on_cover_right.stl` | **Main part** — trackpad frame + factory mounting tab, one piece |
| `tps43_holder_lid.stl` | Thin lid that doubles as the touch overlay (print separately) |
| `tps43_holder_box.stl` | The frame alone, without the mounting tab (standalone use) |
| `tps43_holder.scad` | OpenSCAD source — edit and regenerate if the fit needs tuning |
| `fuse_holder_cover.py` | FreeCAD script that fuses the frame with the cover tab |

Print **`tps43_holder_on_cover_right.stl`** + **`tps43_holder_lid.stl`**.

---

## Bill of materials

- 1 × Azoteq TPS43 trackpad module
- 4 × wires — SDA, SCL, 3V3, GND (discrete wires, not the FPC)
- 2 × M2.5 screws (the ones from the original RP2040 cover)

---

## Print settings

| Setting | Value |
|---------|-------|
| Material | PLA or PETG |
| Layer height | 0.2 mm |
| Perimeters | 3 or more |
| Infill | 20 %+ |
| Supports | **None** |
| Orientation | Flat base down; lid smooth-side up |

The base is flat by design, so no supports are needed. **Preview the slice
first** and confirm no support is being added under the overhang.

---

## Assembly

1. Peel the liner from the pad's factory adhesive. It is on the **sensing
   face** — this is intentional, it's how you bond the overlay.
2. Stick the sensing face to the **underside of the lid**. The lid is the
   surface your finger touches, not the bare pad.
3. Drop the pad + lid into the frame. The internal retention tabs hold it
   captive against the lid.
4. Solder the four wires to the pad and route them out through the open
   bottom, down to the controller.
5. Bolt the piece onto the right half using the two original cover screws.

**Overlay rule:** anything over the sensing face must be **0.2–1.2 mm** thick
and **non-conductive** — no metal, metallic paint, or aluminium tape, or the
pad goes dead.

---

## Firmware

This mount needs firmware built with the QMK/Vial **`azoteq_iqs5xx`**
pointing-device driver. The stock Kea Workshop firmware does **not** include
it — with stock firmware the trackpad will not respond.

- Bus: I2C on pads **D1 = SDA (GP2)** and **D0 = SCL (GP3)**
- Preset: `AZOTEQ_IQS5XX_TPS43`
- Orientation: `AZOTEQ_IQS5XX_ROTATION_270`
- Split: `SPLIT_POINTING_ENABLE` + `POINTING_DEVICE_RIGHT`

Firmware and build notes: https://github.com/jos3duardo/corne-tps43-oled

---

## Tuning the fit

If the pad is tight or loose, edit `tps43_holder.scad` and regenerate:

```sh
openscad -D 'part="box"' -o tps43_holder_box.stl tps43_holder.scad
openscad -D 'part="lid"' -o tps43_holder_lid.stl tps43_holder.scad
flatpak run --command=freecadcmd org.freecad.FreeCAD fuse_holder_cover.py
```

Useful parameters: `tol` (pad clearance), `lid_t` (overlay thickness — kept
within 0.2–1.2 mm by an assert), `tab_*` (retention tabs). In the fusion
script: `COVER_AT` (which side the tab sits), `TRIM_COVER`, `DROP_HOLDER`.

---

## Known limitations

- **Overhang.** The pad is 43 mm wide but the cover tab is ~19 mm, so the
  frame cantilevers past the tab. It's held by two screws at one end; a firm
  press on the far corner may flex it. Consider an extra support foot if you
  find it too springy.
- **Exposed controller.** This part keeps only the cover's mounting tab, not
  its body — the RP2040 is no longer covered by it.
- **Not print-verified here.** Dimensions come from the official Azoteq
  datasheet and the manufacturer's STEP files. Verify the fit on a test
  print before committing to final material.

---

## This project

Firmware, build notes, OpenSCAD/FreeCAD sources and STLs:
**https://github.com/jos3duardo/corne-tps43-oled**

## Credits & license

The mounting tab is **derived from the Corne V4 Pro Micro Edition** cover by
**Kea Workshop (klouderone)**:
https://github.com/klouderone/CorneV4ProMicroEdition

That repository is licensed under **CC BY 4.0** (`LICENSE_CC.txt`) and **MIT**
(`LICENSE_MIT.txt`, © 2023 foostan for the original Corne). Both are permissive
and allow commercial use and modification, requiring only **attribution**.

This derivative is shared under the same terms — attribute Kea Workshop and
foostan if you redistribute or sell it.
