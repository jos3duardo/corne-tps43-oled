/*
Copyright 2019 @foostan
Copyright 2020 Drashna Jaelre <@drashna>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma once

#define VIAL_KEYBOARD_UID {0x3B, 0x6B, 0xA0, 0x29, 0x80, 0x56, 0xED, 0xD1}
#define VIAL_UNLOCK_COMBO_ROWS {0, 0}
#define VIAL_UNLOCK_COMBO_COLS {0, 1}

#undef DYNAMIC_KEYMAP_LAYER_COUNT
#define DYNAMIC_KEYMAP_LAYER_COUNT 4
#define TAPPING_TERM 180

//#define USE_MATRIX_I2C
#ifdef KEYBOARD_crkbd_rev1_legacy
#    undef USE_I2C
#    define USE_SERIAL
#endif

/* Select hand configuration */

// #define MASTER_LEFT
// #define MASTER_RIGHT
#define EE_HANDS

#define USE_SERIAL_PD2
#ifdef RGBLIGHT_ENABLE
#    undef RGBLIGHT_LED_COUNT
#    define RGBLIGHT_ANIMATIONS
#    define RGBLIGHT_LED_COUNT 54
#    undef RGBLED_SPLIT
#    define RGBLED_SPLIT \
        { 27, 27 }
#    define RGBLIGHT_LIMIT_VAL 120
#    define RGBLIGHT_HUE_STEP  10
#    define RGBLIGHT_SAT_STEP  17
#    define RGBLIGHT_VAL_STEP  17
#endif

#define OLED_FONT_H "keyboards/crkbd/lib/glcdfont.c"

/* Sincroniza estado pelo link split, para o OLED (que fica na metade ESQUERDA)
 * renderizar o mesmo conteudo mesmo quando ela for slave — ou seja, quando o
 * cabo USB estiver na direita. Sem isto o slave nao conhece camada/mods/WPM. */
#define SPLIT_LAYER_STATE_ENABLE
#define SPLIT_MODS_ENABLE
#define SPLIT_WPM_ENABLE
#define SPLIT_LED_STATE_ENABLE

/* ---- Trackpad Azoteq TPS43 (chip IQS572) na metade direita ----
 * CONFIRMADO em 23/07/2026: esta no barramento I2C do OLED (pads D1/D0).
 * No RP2040 a funcao e fixa: GP2 so faz SDA, GP3 so faz SCL.
 * OLED (0x3C) e TPS43 (0x74) convivem no mesmo barramento.
 */
#define AZOTEQ_IQS5XX_TPS43

/* Orientacao do pad determinada empiricamente em 23/07/2026.
 * Testados nesta ordem: 180 -> eixos trocados entre si;
 *                        90 -> eixos alinhados, porem ambos invertidos;
 *                       270 -> correto.
 * Nao vale deduzir no papel: a ordem em que o IQS572 aplica flip_x/flip_y e
 * switch_xy_axis no registrador XY_CONFIG_0 nao e a intuitiva. */
#define AZOTEQ_IQS5XX_ROTATION_270
#define SPLIT_POINTING_ENABLE
#define POINTING_DEVICE_RIGHT

#define I2C_DRIVER   I2CD1
/* Com CONVERT_TO ativo valem os nomes Pro Micro, nao GPxx.
 * Pad D1 = GP2 (unica opcao de SDA), pad D0 = GP3 (unica opcao de SCL). */
#define I2C1_SDA_PIN D1
#define I2C1_SCL_PIN D0

#define AZOTEQ_IQS5XX_TAP_ENABLE true
#define AZOTEQ_IQS5XX_TWO_FINGER_TAP_ENABLE true
#define AZOTEQ_IQS5XX_SCROLL_ENABLE true
#define AZOTEQ_IQS5XX_PRESS_AND_HOLD_ENABLE true
