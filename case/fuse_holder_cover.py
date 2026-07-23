# Funde o suporte da TPS43 com a tampa original da Kea Workshop.
#
# A tampa vem do repo do fabricante (STEP), entao a interface de fixacao —
# contorno e os dois furos Ø2,30 mm — e exatamente a original, nao uma
# reproducao aproximada. O suporte vem do OpenSCAD, via STL.
#
# Rodar:
#   flatpak run --command=freecadcmd org.freecad.FreeCAD fuse_holder_cover.py

import FreeCAD, Part, Mesh, os
from FreeCAD import Vector

BASE = "/home/jsouza/projects/corne-firmware/case"
COVER = os.path.join(BASE, "ref_no_display_cover_right.stp")
HOLDER = os.path.join(BASE, "tps43_holder_box.stl")
OUT = os.path.join(BASE, "tps43_holder_on_cover_right")

# Onde centrar o suporte sobre a tampa. O padrao e o centro da janela do
# OLED (medido na OLED Cover: rel 8,47 x 38,40), que e a area livre da peca.
CENTER_REL = (8.47, 38.40)

# Passagem dos fios atraves da tampa, ate o RP2040 logo abaixo.
WIRE_SLOT = (10.0, 20.0)   # largura x comprimento, mm

cover = Part.Shape()
cover.read(COVER)
cb = cover.BoundBox
print(f"tampa : {cb.XLength:.2f} x {cb.YLength:.2f} x {cb.ZLength:.2f} mm")

mesh = Mesh.Mesh(HOLDER)
shell = Part.Shape()
shell.makeShapeFromMesh(mesh.Topology, 0.05)
holder = Part.Solid(shell).removeSplitter()
hb = holder.BoundBox
print(f"suporte: {hb.XLength:.2f} x {hb.YLength:.2f} x {hb.ZLength:.2f} mm")

# posiciona: centrado no ponto escolhido, assentado no topo da tampa
tx = cb.XMin + CENTER_REL[0] - hb.XLength / 2 - hb.XMin
ty = cb.YMin + CENTER_REL[1] - hb.YLength / 2 - hb.YMin
tz = cb.ZMax - hb.ZMin
holder.translate(Vector(tx, ty, tz))

fused = cover.fuse(holder).removeSplitter()

# fura a tampa para os fios descerem ate o controlador
cx = cb.XMin + CENTER_REL[0]
cy = cb.YMin + CENTER_REL[1]
slot = Part.makeBox(
    WIRE_SLOT[0], WIRE_SLOT[1], cb.ZLength + 2,
    Vector(cx - WIRE_SLOT[0] / 2, cy - WIRE_SLOT[1] / 2, cb.ZMin - 1),
)
fused = fused.cut(slot).removeSplitter()

fb = fused.BoundBox
print(f"fundido: {fb.XLength:.2f} x {fb.YLength:.2f} x {fb.ZLength:.2f} mm"
      f"   volume {fused.Volume:.1f} mm3   solidos {len(fused.Solids)}")
assert len(fused.Solids) == 1, "resultado ficou em pedacos soltos!"

fused.exportStep(OUT + ".stp")
Mesh.Mesh(fused.tessellate(0.05)).write(OUT + ".stl")
print("gerado:", OUT + ".stp / .stl")
