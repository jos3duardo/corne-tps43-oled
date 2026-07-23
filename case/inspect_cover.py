import FreeCAD, Part, os
from FreeCAD import Vector

BASE = "/home/jsouza/projects/corne-firmware/case"

def inspect(fname):
    path = os.path.join(BASE, fname)
    if not os.path.exists(path):
        print(f"\n### {fname}: NAO BAIXADO"); return
    shape = Part.Shape(); shape.read(path)
    bb = shape.BoundBox
    print(f"\n### {fname}")
    print(f"  bbox {bb.XLength:.2f} x {bb.YLength:.2f} x {bb.ZLength:.2f} mm"
          f"   volume {shape.Volume:.1f} mm3")

    # Fatia em varias alturas. Contornos internos = furos/recortes.
    for frac in (0.15, 0.5, 0.85):
        z = bb.ZMin + bb.ZLength * frac
        wires = shape.slice(Vector(0, 0, 1), z)
        print(f"\n  --- corte em z={z:.2f} ({len(wires)} contornos) ---")
        info = []
        for w in wires:
            wb = w.BoundBox
            info.append((wb.XLength * wb.YLength, wb))
        info.sort(reverse=True, key=lambda t: t[0])
        for i, (a, wb) in enumerate(info):
            papel = "externo" if i == 0 else "INTERNO"
            print(f"    {papel:8s} {wb.XLength:6.2f} x {wb.YLength:6.2f} mm"
                  f"   centro=({wb.Center.x:7.2f}, {wb.Center.y:7.2f})"
                  f"   rel=({wb.Center.x-bb.XMin:6.2f}, {wb.Center.y-bb.YMin:6.2f})")

for f in ("ref_no_display_cover_right.stp", "ref_oled_cover_right.stp"):
    inspect(f)
