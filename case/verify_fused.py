import FreeCAD, Part
from FreeCAD import Vector
s = Part.Shape(); s.read("/home/jsouza/projects/corne-firmware/case/tps43_holder_on_cover_right.stp")
bb = s.BoundBox
print(f"peca: {bb.XLength:.2f} x {bb.YLength:.2f} x {bb.ZLength:.2f}  solidos={len(s.Solids)}")
for frac in (0.1, 0.25, 0.6, 0.9):
    z = bb.ZMin + bb.ZLength*frac
    ws = s.slice(Vector(0,0,1), z)
    dims = sorted(((w.BoundBox.XLength, w.BoundBox.YLength, w.BoundBox.Center) for w in ws),
                  key=lambda t: -(t[0]*t[1]))
    print(f"\n z={z:.2f}  ({len(ws)} contornos)")
    for i,(x,y,c) in enumerate(dims):
        tag = "externo" if i==0 else "interno"
        print(f"   {tag} {x:6.2f} x {y:6.2f}  centro=({c.x:7.2f},{c.y:7.2f})")
