import FreeCAD, Part, math
s = Part.Shape(); s.read("/home/jsouza/projects/corne-firmware/case/tps43_holder_on_cover_right.stp")
bb = s.BoundBox
print(f"peca: {bb.XLength:.2f} x {bb.YLength:.2f} x {bb.ZLength:.2f}  Zmin={bb.ZMin:.2f}  solidos={len(s.Solids)}")
# soma da area de faces cuja normal aponta para baixo e que ficam no plano de base
base_area=0.0; other_low=0.0
for f in s.Faces:
    u=f.ParameterRange
    n=f.normalAt((u[0]+u[1])/2,(u[2]+u[3])/2)
    fb=f.BoundBox
    if n.z < -0.9 and fb.ZMax < bb.ZMin + 0.05:
        base_area += f.Area
print(f"area de face no plano da base (contato com a mesa): {base_area:.1f} mm2")
print(f"footprint total do aro (48.9x45.9): {48.9*45.9:.0f} mm2")
