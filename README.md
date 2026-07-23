# Corne V4 Pro Micro Edition — firmware

Customizações de firmware do meu teclado split **Corne V4 Pro Micro Edition**
(PCB da [Kea Workshop](https://github.com/klouderone/CorneV4ProMicroEdition)),
com trackpad Azoteq TPS43 e OLED.

Este repositório guarda apenas o **keymap** e os binários. O QMK em si não é
versionado aqui — ele é um clone do [vial-qmk](https://github.com/vial-kb/vial-qmk).

## Hardware

| Item | Detalhe |
|---|---|
| Controladores | RP2040 Pro Micro genérico, `CONVERT_TO = rp2040_ce` |
| Alvo QMK | `crkbd/rev1`, layout `LAYOUT_split_3x6_3` (42 teclas) |
| Trackpad | Azoteq **TPS43** (chip IQS572), metade **direita** |
| OLED | SSD1306 128x32, metade **esquerda** |
| Lateralidade | `EE_HANDS` — firmware específico por metade |

### Pinagem do trackpad

Está no mesmo barramento I2C do OLED. Com `CONVERT_TO` ativo valem os nomes
Pro Micro, não `GPxx`:

| Sinal | Pad | GPIO | Observação |
|---|---|---|---|
| SDA | `D1` | GP2 | No RP2040 a função é fixa: GP2 **só** faz SDA |
| SCL | `D0` | GP3 | GP3 **só** faz SCL |

⚠️ Isso é o **inverso** da serigrafia do Pro Micro AVR, onde `D1`=SCL e `D0`=SDA.
É a causa nº 1 de trackpad ou OLED mudo neste hardware.

## Estrutura

```
keymap/      fonte do keymap — symlinkado para dentro do vial-qmk
firmware/    binários compilados, prontos para gravar
  stock/     firmware original do fabricante (rollback conhecido-bom)
tools/       scripts de bootloader e gravação
case/        suporte 3D do trackpad (OpenSCAD paramétrico + STLs)
```

## Suporte 3D do trackpad

`case/tps43_holder.scad` — peça **avulsa**, não integrada ao case da Kea Workshop.
Não existe modelo público de Corne com TPS43; este foi feito com as cotas do
datasheet oficial.

| Peça | Dimensões |
|---|---|
| `tps43_holder_box.stl` | 48,9 × 45,9 × 6,0 mm |
| `tps43_holder_lid.stl` | 45,3 × 42,3 × 0,6 mm |

**Montagem — a ordem importa.** O adesivo de fábrica está na *face sensível* do pad.
Cole essa face na parte **de baixo da tampa**: a tampa é o overlay, e é nela que o
dedo toca. Depois encaixe o conjunto na caixa, com o cabo saindo pelo rasgo lateral.

Regenerar após mexer nos parâmetros:

```sh
cd case
openscad -D 'part="box"' -o tps43_holder_box.stl tps43_holder.scad
openscad -D 'part="lid"' -o tps43_holder_lid.stl tps43_holder.scad
```

Parâmetros úteis: `tol` (folga do pad), `lid_t` (espessura do overlay — o datasheet
exige **0,2 a 1,2 mm**, e há um `assert` que barra valores fora disso), `box_h`
(altura do corpo), `wire_d`/`wire_x`/`wire_edge` (passagem dos fios pelo fundo).

**`open_bottom = true` (padrão): a peça é um aro, sem piso.** O pad fica pendurado
pela tampa — à qual está colado — e os fios (SDA, SCL, 3V3, GND, soltos, não o cabo
flat) saem direto pela abertura inferior. A ideia é colar esse aro sobre a tampa que
cobre o RP2040, que passa a fazer as vezes de fundo.

Com `open_bottom = false` a peça ganha piso, furo de passagem com chanfro
(`wire_d`, `wire_x`, `wire_edge`) e, opcionalmente, os furos de fixação.

### Peça fundida com a tampa do fabricante

`tps43_holder_on_cover_right.stl` / `.stp` — **48,90 × 61,35 × 6,00 mm**, peça única.

É o suporte unido à tampa *No Display Cover Right* original da Kea Workshop. Como a
tampa vem do STEP do fabricante, a interface de fixação é a original, não uma
reprodução: os dois furos **Ø2,30 mm** ficam preservados nas coordenadas de fábrica,
então parafusa com os mesmos parafusos, sem furar nada.

Inclui uma passagem de 10 × 20 mm atravessando a tampa, para os fios descerem até o
RP2040. O suporte fica centrado onde a *OLED Cover* põe a janela do display
(rel 8,47 × 38,40), que é a área livre da peça.

Regenerar após mexer no suporte:

```sh
flatpak run --command=freecadcmd org.freecad.FreeCAD fuse_holder_cover.py
```

Ajuste `CENTER_REL` (posição sobre a tampa) e `WIRE_SLOT` (passagem dos fios) no
topo do script.

### Cotas da tampa — medidas com FreeCAD

| Medida | No Display | OLED Cover |
|---|---|---|
| Footprint | 18,97 × 58,95 mm | igual |
| Altura | 3,05 mm | 4,05 mm |
| Furos | 2 × Ø2,30 mm | iguais |
| Posição dos furos (do canto) | (2,27 · 2,68) e (16,70 · 9,07) | iguais |
| Janela do display | — | 12,50 × 39,80 em (8,47 · 38,40) |

Distância entre centros dos furos: **15,78 mm**.

⚠️ O acrílico do OLED usa fixação **diferente** (Ø2,82 mm, 18,43 mm entre centros).
Não confunda: a tabela acima vale para as tampas impressas.

O STEP exporta tudo como B-spline, então detectar círculo por raio não funciona.
`inspect_cover.py` contorna isso fatiando o sólido e lendo os contornos internos.

### Ressalvas da fixação

A ideia é prender o suporte onde hoje fica a tampa que cobre o RP2040. Cotas do
**acrílico do OLED** da Kea Workshop, extraídas do SVG oficial:

| Medida | Valor |
|---|---|
| Contorno | 22,39 × 71,42 mm |
| Furos | Ø2,82 mm (folga M2.5) |
| Distância entre centros | 18,43 mm |
| Posição (do canto) | A(19,62 · 61,02) · B(2,77 · 68,48) |

⚠️ **Isso é da peça de acrílico, não da tampa "No Display".** O STEP da No Display
tem caixa envolvente de 86,26 × 59,22 × 11,63 mm — é uma casca 3D bem maior, e não
foi confirmado que use a mesma interface de fixação. Meça a sua antes de furar.

Dois problemas conhecidos dessa fixação:

1. **A TPS43 tem 43 mm de largura; a área da tampa, ~22 mm.** Com o suporte, são
   48,9 mm sobre uma base de 22 — cerca de 13 mm de balanço por lado, avançando
   sobre os switches.
2. **Os dois furos ficam agrupados numa ponta** (18,43 mm entre si, numa peça de
   71 mm). Segura uma tampa leve, mas um conjunto trackpad+suporte vira alavanca e
   tende a flexionar justamente ao toque.

Provável necessidade de apoio adicional além dos parafusos. O parâmetro
`mount_holes` (padrão `false`) cria os dois furos com essas cotas, para quando a
fixação estiver definida.

⚠️ Nada condutivo pode entrar na camada do overlay — sem tinta metálica, sem fita
de alumínio, sem chapa encostando na face sensível.

## Como compilar

Pré-requisitos: `gcc-arm-none-eabi` e o vial-qmk clonado em `~/projects/vial-qmk`
com um venv em `.venv` (contendo `qmk` e as deps do `requirements.txt`).

O keymap entra na árvore do QMK por symlink, o que mantém o clone do upstream
sem modificações:

```sh
ln -sfn ~/projects/corne-firmware/keymap \
        ~/projects/vial-qmk/keyboards/crkbd/keymaps/jos3duardo
```

Compilar:

```sh
cd ~/projects/vial-qmk
export PATH="$PWD/.venv/bin:$PATH"
make crkbd/rev1:jos3duardo:uf2-split-left     # metade esquerda
make crkbd/rev1:jos3duardo:uf2-split-right    # metade direita
```

Os alvos `uf2-split-*` **tentam gravar** depois de compilar e ficam pendurados se
não houver placa em BOOTSEL. Não tem problema: o `.uf2` já foi gerado antes disso,
em `crkbd_rev1_jos3duardo.uf2` na raiz do vial-qmk. Interrompa e copie o arquivo.

## Como gravar

### Entrar em BOOTSEL

Segurar o botão **BOOT** e plugar o USB. Funciona sempre, independente do firmware.
Depois de plugado, **não mexer** — um replug ou reset tira a placa do bootloader.

O duplo toque no reset **não funciona** neste hardware.

Se a placa ainda estiver com o MicroPython de fábrica (`2e8a:0005`), dá para
comandar por software: `tools/enter-bootloader.sh`

### Gravar

```sh
tools/flash.sh firmware/vial_tp_left.uf2
```

O script espera o `RPI-RP2` montar e copia o arquivo.

### Identificar qual metade está na mão

As duas expõem USB **idêntico**, inclusive o mesmo número de série — não dá para
distinguir por software. Plugue uma só e digite uma tecla da fileira do meio:

- `A S D F` → esquerda
- `H J K L` → direita

**Faça isso antes de cada gravação.** Gravar a lateralidade trocada faz as teclas
saírem deslocadas e o trackpad parar de responder, porque `POINTING_DEVICE_RIGHT`
passa a esperar o sensor do outro lado.

## Notas

- **Trocar de firmware perde os remaps do Vial**, porque muda a identidade USB do
  teclado. O firmware do fabricante se identifica como `Kea Workshop Corne V4`;
  este aqui, como `foostan Corne`.
- **O firmware do fabricante não inclui o driver Azoteq** — com ele o trackpad não
  funciona, mesmo com a fiação correta.
- A rotação do trackpad (`AZOTEQ_IQS5XX_ROTATION_270`) foi encontrada por tentativa.
  Não vale deduzir no papel: a ordem em que o IQS5xx aplica `flip_x`/`flip_y`/
  `switch_xy_axis` não é a intuitiva. Atalho: eixos **trocados entre si** → tente
  90/270; eixos **alinhados mas ambos invertidos** → some 180 ao preset atual.
- A fita dupla-face que vem na face sensível do trackpad é **intencional** (3M 468,
  0,13 mm, com liner de papel e aba de puxar). Serve para colar o overlay, que deve
  ficar entre **0,2 e 1,2 mm** e não pode ser condutivo.
