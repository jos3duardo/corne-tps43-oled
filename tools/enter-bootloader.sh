#!/usr/bin/env bash
# Coloca em BOOTSEL um RP2040 que ainda esteja com o MicroPython de fabrica.
#
# Os controladores genericos vem com MicroPython gravado, que NAO implementa o
# double-tap-reset -> BOOTSEL do QMK. O reset so reinicia o Python, o drive
# RPI-RP2 nunca aparece, e parece defeito de hardware. Este script comanda o
# bootloader pelo REPL.
#
# Se a placa ja estiver com QMK, este script nao serve: use o botao BOOT.
set -euo pipefail

port="${1:-/dev/ttyACM0}"

if [ ! -e "$port" ]; then
    echo "erro: $port nao existe" >&2
    echo "a placa esta com MicroPython? procure por 2e8a:0005 em 'lsusb'" >&2
    exit 1
fi

stty -F "$port" raw -echo 115200
exec 3<>"$port"
printf '\r\x03\x03\r' >&3        # Ctrl-C duplo: interrompe script e cai no REPL
sleep 1
printf 'import machine\r\n' >&3
sleep 1
printf 'machine.bootloader()\r\n' >&3
sleep 2
exec 3<&-

echo "comando enviado; aguardando RPI-RP2..."
for _ in $(seq 1 15); do
    if lsblk -o LABEL -nr | grep -qx RPI-RP2; then
        echo "OK: placa em BOOTSEL"
        exit 0
    fi
    sleep 1
done

echo "RPI-RP2 nao apareceu" >&2
exit 1
