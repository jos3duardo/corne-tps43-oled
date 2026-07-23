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
```

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
