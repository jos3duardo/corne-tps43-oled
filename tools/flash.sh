#!/usr/bin/env bash
# Espera uma metade entrar em BOOTSEL e grava o .uf2 informado.
#
#   tools/flash.sh firmware/vial_tp_left.uf2
#
# Coloque a placa em BOOTSEL segurando BOOT e plugando o USB. Depois de plugada,
# nao mexa: um replug ou reset a tira do bootloader e a janela se fecha.
#
# ATENCAO: confirme qual metade esta na mao antes de gravar. As duas expoem USB
# identico. Plugue uma so e digite uma tecla da fileira do meio:
# A S D F = esquerda, H J K L = direita.
set -euo pipefail

fw="${1:-}"
timeout_s="${2:-600}"

if [ -z "$fw" ] || [ ! -f "$fw" ]; then
    echo "uso: $0 <arquivo.uf2> [timeout_segundos]" >&2
    exit 1
fi

echo "aguardando BOOTSEL (ate ${timeout_s}s)..."
mnt=""
for _ in $(seq 1 $((timeout_s / 2))); do
    mnt=$(lsblk -o LABEL,MOUNTPOINT -nr | awk '$1=="RPI-RP2"{print $2}' | head -1)
    [ -n "$mnt" ] && break
    sleep 2
done

if [ -z "$mnt" ]; then
    echo "timeout: RPI-RP2 nao apareceu. Nada foi gravado." >&2
    exit 1
fi

echo "RPI-RP2 em: $mnt"
# O erro de I/O aqui e esperado: a placa reinicia sozinha ao concluir a gravacao.
cp "$fw" "$mnt/" || true
sync || true
echo "gravado: $(basename "$fw")"

sleep 8
echo "--- enumeracao apos o reboot ---"
lsusb | grep -iE '4653|2e8a' || echo "nada enumerado ainda"
