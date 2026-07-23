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
// open_bottom = true deixa a peca sem piso, como um aro: o pad fica
// pendurado pela tampa (a qual ele esta colado) e os fios saem direto pela
// abertura inferior. E a forma pensada para colar sobre a tampa do RP2040,
// que passa a fazer as vezes de fundo.
open_bottom = true;

box_h     = 6.0; // altura total
wall_t    = 1.6; // parede lateral
base_t    = 1.2; // piso — ignorado quando open_bottom = true
lid_t     = 0.6; // tampa = overlay. MANTENHA entre 0.2 e 1.2
lid_ledge = 1.0; // largura do ressalto onde a tampa apoia

/* [Retencao do pad] */
// Travas que avancam para dentro da cavidade e seguram o pad POR BAIXO,
// prensando-o contra a tampa. Sem elas o pad fica preso so pelo adesivo.
// Ficam posicionadas em relacao ao TOPO, entao valem para qualquer box_h.
tabs     = true;
tab_t    = 1.0;  // espessura (quanto sobe)
tab_in   = 1.5;  // quanto avanca para dentro
tab_len  = 8.0;  // comprimento de cada trava
tab_slack= 0.15; // folga vertical, para nao esmagar o PCB

/* [Impressao] */
tol     = 0.35;  // folga por lado; aumente se ficar apertado
lid_gap = 0.20;  // folga extra so da tampa, para ela entrar sem forcar

/* [Saida dos fios] */
// Saida pelo FUNDO, nao pela lateral: a montagem usa fios soltos
// (SDA, SCL, 3V3, GND), nao o cabo flat.
wire_d    = 5.0;  // diametro do furo de passagem
wire_x    = 0.5;  // posicao no eixo X, como fracao da largura (0..1)
wire_edge = 8.0;  // distancia do centro do furo ate a borda Y mais proxima

/* [Fixacao — OPCIONAL, NAO VERIFICADO] */
// Furos com a cota da tampa ACRILICA do OLED da Kea Workshop
// (Ø2,82 mm, 18,43 mm entre centros), extraidas do SVG oficial.
// ATENCAO: NAO foi confirmado que a tampa "No Display" usa a mesma
// interface — ela e uma casca 3D bem maior. Meca a sua antes de usar.
mount_holes = false;
mount_d     = 2.82;
mount_pitch = 18.43;

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

floor_t  = open_bottom ? 0 : base_t;
cavity_h = box_h - lid_t - floor_t; // espaco util interno

module rounded_cube(x, y, z, r) {
    hull() for (dx = [r, x-r], dy = [r, y-r])
        translate([dx, dy, 0]) cylinder(r = r, h = z);
}

// Z onde a face de baixo do pad fica, medido a partir do topo.
pad_h     = tp_pcb + tp_adh;
pad_bot_z = box_h - lid_t - pad_h - tab_slack;

// Travas de retencao: quatro linguetas apontando para dentro da cavidade,
// logo abaixo do pad. O espaco entre elas fica livre para os fios.
module retention_tabs() {
    px = wall_t + lid_ledge;          // canto da cavidade
    py = wall_t + lid_ledge;
    translate([0, 0, pad_bot_z - tab_t]) {
        // duas nas laterais longas
        for (y = [py + (pocket_d - tab_len)/2])
            for (x = [px, px + pocket_w - tab_in])
                translate([x, y, 0]) cube([tab_in, tab_len, tab_t]);
        // duas nas laterais curtas
        for (x = [px + (pocket_w - tab_len)/2])
            for (y = [py, py + pocket_d - tab_in])
                translate([x, y, 0]) cube([tab_len, tab_in, tab_t]);
    }
}

module box() {
    assert(cavity_h >= tp_pcb + tp_adh,
           "cavidade menor que o pad: aumente box_h");
    assert(lid_t >= 0.2 && lid_t <= 1.2,
           "lid_t fora da faixa de overlay do datasheet (0,2 a 1,2 mm)");
    assert(!tabs || pad_bot_z - tab_t >= 0,
           "travas ficariam abaixo da peca: aumente box_h");

    if (tabs) retention_tabs();

    difference() {
        rounded_cube(box_w, box_d, box_h, box_r);

        // cavidade interna: abriga o pad; sem piso, atravessa a peca toda
        translate([wall_t + lid_ledge, wall_t + lid_ledge, floor_t - 0.1])
            rounded_cube(pocket_w, pocket_d, cavity_h + 0.2, pocket_r);

        // rebaixo da tampa, aberto no topo
        translate([wall_t, wall_t, box_h - lid_t])
            rounded_cube(recess_w, recess_d, lid_t + 0.1, recess_r);

        // Com piso, os fios precisam de furo e chanfro. Sem piso, saem
        // pela propria abertura inferior.
        if (!open_bottom) {
            translate([box_w * wire_x, wire_edge, -0.1])
                cylinder(d = wire_d, h = base_t + 0.2);
            translate([box_w * wire_x, wire_edge, -0.01])
                cylinder(d1 = wire_d + 1.6, d2 = wire_d, h = 0.8);
        }

        // furos de fixacao, se habilitados (so fazem sentido com piso)
        if (mount_holes && !open_bottom)
            for (dx = [-mount_pitch/2, mount_pitch/2])
                translate([box_w/2 + dx, box_d - wire_edge, -0.1])
                    cylinder(d = mount_d, h = base_t + 0.2);
    }
}

// Tampa: e o overlay. Imprima com a face lisa para cima, sem suporte.
module lid() {
    rounded_cube(recess_w - 2*lid_gap, recess_d - 2*lid_gap, lid_t,
                 recess_r - lid_gap);
}

if (part == "box" || part == "both") box();
if (part == "lid" || part == "both") translate([0, box_d + 6, 0]) lid();
