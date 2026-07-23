// Suporte avulso para trackpad Azoteq TPS43
// -----------------------------------------------------------------------------
// Cotas do datasheet oficial "ProxSense Standard Trackpad Module" v1.02:
//   - TPS43: 43,0 x 40,0 mm, chip IQS572
//   - PCB: FR4, espessura final 1,0 mm +/- 10%
//   - Adesivo de fabrica: 3M 468 200MP, 0,13 mm, na FACE SENSIVEL
//   - Overlay compativel: 0,2 a 1,2 mm (acima disso exige firmware especial)
//
// MONTAGEM (a ordem importa):
//   1. Puxe o liner de papel pela aba.
//   2. Cole a face sensivel do pad na parte DE BAIXO da tampa (`lid`).
//      A tampa E o overlay — e nela que seu dedo toca, nao no pad.
//   3. Encaixe o conjunto tampa+pad na caixa, cabo saindo pelo rasgo lateral.
//   4. A tampa assenta num rebaixo de `lid_ledge` mm, ficando rente ao topo.
//
// `lid_t` tem que ficar entre 0,2 e 1,2 mm. O padrao de 0,6 mm da boa margem e
// imprime bem em bico de 0,4 mm. NADA CONDUTIVO nessa camada — sem tinta
// metalica, sem fita de aluminio, sem chapa encostando na face sensivel.
//
// Corte em Z, de baixo para cima:
//   0            .. base_t              piso solido
//   base_t       .. box_h - lid_t       cavidade: pad + folga para o cabo FPC
//   box_h-lid_t  .. box_h               rebaixo onde a tampa assenta
// -----------------------------------------------------------------------------

$fn = 60;

/* [Trackpad] */
tp_w   = 43.0;   // largura do modulo
tp_d   = 40.0;   // profundidade do modulo
tp_pcb = 1.0;    // espessura do PCB
tp_adh = 0.13;   // adesivo de fabrica
tp_r   = 2.5;    // raio dos cantos

/* [Corpo] */
box_h     = 6.0; // altura total. Da corpo a peca e espaco para o cabo
wall_t    = 1.6; // parede lateral
base_t    = 1.2; // piso
lid_t     = 0.6; // tampa = overlay. MANTENHA entre 0.2 e 1.2
lid_ledge = 1.0; // largura do ressalto onde a tampa apoia

/* [Impressao] */
tol     = 0.35;  // folga por lado; aumente se ficar apertado
lid_gap = 0.20;  // folga extra so da tampa, para ela entrar sem forcar

/* [Saida do cabo] */
cable_w = 12.0;  // largura do rasgo (FPC da TPS43)

/* [Render] */
part = "both";   // "box", "lid" ou "both"

// -----------------------------------------------------------------------------

pocket_w = tp_w + 2*tol;          // cavidade que abriga o pad
pocket_d = tp_d + 2*tol;
pocket_r = tp_r + tol;

recess_w = pocket_w + 2*lid_ledge; // rebaixo da tampa, maior que a cavidade
recess_d = pocket_d + 2*lid_ledge; // — a diferenca forma o ressalto de apoio
recess_r = pocket_r + lid_ledge;

box_w = recess_w + 2*wall_t;
box_d = recess_d + 2*wall_t;
box_r = recess_r + wall_t;

cavity_h = box_h - lid_t - base_t; // espaco util interno

module rounded_cube(x, y, z, r) {
    hull() for (dx = [r, x-r], dy = [r, y-r])
        translate([dx, dy, 0]) cylinder(r = r, h = z);
}

module box() {
    assert(cavity_h >= tp_pcb + tp_adh,
           "cavidade menor que o pad: aumente box_h");
    assert(lid_t >= 0.2 && lid_t <= 1.2,
           "lid_t fora da faixa de overlay do datasheet (0,2 a 1,2 mm)");

    difference() {
        rounded_cube(box_w, box_d, box_h, box_r);

        // cavidade interna: abriga o pad e sobra folga para o cabo
        translate([wall_t + lid_ledge, wall_t + lid_ledge, base_t])
            rounded_cube(pocket_w, pocket_d, cavity_h, pocket_r);

        // rebaixo da tampa, aberto no topo
        translate([wall_t, wall_t, box_h - lid_t])
            rounded_cube(recess_w, recess_d, lid_t + 0.1, recess_r);

        // rasgo lateral para o cabo sair
        translate([box_w - wall_t - 0.1, (box_d - cable_w)/2, base_t])
            cube([wall_t + 0.2, cable_w, cavity_h]);
    }
}

// Tampa: e o overlay. Imprima com a face lisa para cima, sem suporte.
module lid() {
    rounded_cube(recess_w - 2*lid_gap, recess_d - 2*lid_gap, lid_t,
                 recess_r - lid_gap);
}

if (part == "box" || part == "both") box();
if (part == "lid" || part == "both") translate([0, box_d + 6, 0]) lid();
