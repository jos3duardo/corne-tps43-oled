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

# Posicao do suporte sobre a tampa, no eixo Y (ao longo do comprimento).
# O padrao e a altura da janela do OLED (rel 38,40), que e a area livre.
CENTER_Y_REL = 38.40

# Alinhamento no eixo X. A tampa tem so 18,97 mm de largura e o suporte tem
# 48,90 — entao a tampa nunca cobre a peca toda, e a questao e para que lado
# sobra o balanco.
#   "xmax"   -> tampa encostada na borda +X do suporte (sobra para -X)
#   "xmin"   -> tampa encostada na borda -X do suporte (sobra para +X)
#   "center" -> tampa no meio (sobra dos dois lados)
# ATENCAO: +X do STEP nao necessariamente e a sua "direita" visual. Se sair
# para o lado errado, troque "xmax" por "xmin".
COVER_AT = "xmax"

# Passagem dos fios atraves da tampa, ate o RP2040 logo abaixo.
WIRE_SLOT = (10.0, 20.0)   # largura x comprimento, mm

# DROP_HOLDER: assenta a base do aro no MESMO plano da base da tampa, em vez
# de no topo dela. Sem isso, o balanco do aro (~30 mm que passam da largura da
# tampa) fica flutuando a 3 mm da mesa e o fatiador poe suporte embaixo. Com
# isso, toda a face inferior toca a mesa — imprime sem suporte. A regiao
# sobreposta com a tampa se funde num solido so.
# ATENCAO: baixar preenche o espaco ABAIXO do balanco. Confirme que sobra
# folga sobre os switches do teclado ali; se nao sobrar, a saia vai colidir.
DROP_HOLDER = True

# TRIM_COVER: descarta o corpo da tampa que fica sob o aro (redundante, ja
# coberto pelo modelo) e mantem apenas a ABA de fixacao — o extremo com os
# dois furos que prende no RP2040. A peca final vira: aro + aba de fixacao.
# OVERLAP_WELD e quanto da tampa continua entrando sob o aro, para a solda
# das duas partes ser volumetrica e nao so encostada.
TRIM_COVER = True
OVERLAP_WELD = 3.0   # mm

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

# posiciona: assentado no topo da tampa, alinhado conforme COVER_AT
if COVER_AT == "xmax":
    tx = cb.XMax - hb.XMax                      # bordas +X coincidem
elif COVER_AT == "xmin":
    tx = cb.XMin - hb.XMin                      # bordas -X coincidem
else:
    tx = cb.XMin + cb.XLength / 2 - hb.XLength / 2 - hb.XMin

ty = cb.YMin + CENTER_Y_REL - hb.YLength / 2 - hb.YMin
# base do aro coplanar com a base da tampa (DROP) ou assentada no topo dela
tz = (cb.ZMin - hb.ZMin) if DROP_HOLDER else (cb.ZMax - hb.ZMin)
holder.translate(Vector(tx, ty, tz))

hb2 = holder.BoundBox
print(f"alinhamento '{COVER_AT}': suporte X {hb2.XMin:.2f}..{hb2.XMax:.2f}"
      f" | tampa X {cb.XMin:.2f}..{cb.XMax:.2f}")
print(f"  balanco: {cb.XMin - hb2.XMin:+.2f} mm em -X, "
      f"{hb2.XMax - cb.XMax:+.2f} mm em +X")

# Opcional: reduz a tampa a apenas a aba de fixacao. Remove tudo com Y acima
# da linha de corte; a aba (Y baixo, onde estao os furos) e um refugo de
# OVERLAP_WELD mm sob o aro permanecem, garantindo a solda.
if TRIM_COVER:
    y_cut = hb2.YMin + OVERLAP_WELD
    holes_y = [-11.68, -18.07]   # medidos em inspect_cover.py
    assert all(y < y_cut for y in holes_y), \
        "a linha de corte cairia sobre os furos de fixacao"
    prism = Part.makeBox(
        cb.XLength + 2, (cb.YMax - y_cut) + 2, cb.ZLength + 2,
        Vector(cb.XMin - 1, y_cut, cb.ZMin - 1),
    )
    cover_use = cover.cut(prism).removeSplitter()
else:
    cover_use = cover

fused = cover_use.fuse(holder).removeSplitter()

# A passagem de fios pela tampa so faz sentido se a tampa inteira ficou. Com a
# tampa recortada, o fundo do aro ja e aberto e os fios saem por ali direto.
if not TRIM_COVER:
    cx = cb.XMin + cb.XLength / 2
    cy = cb.YMin + CENTER_Y_REL
    assert WIRE_SLOT[0] < cb.XLength, "rasgo mais largo que a tampa"
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
