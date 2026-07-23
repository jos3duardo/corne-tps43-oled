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

#include QMK_KEYBOARD_H

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [0] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,                         KC_Y,    KC_U,    KC_I,    KC_O,   KC_P,  KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LCTL,    KC_A,    KC_S,    KC_D,    KC_F,    KC_G,                         KC_H,    KC_J,    KC_K,    KC_L, KC_SCLN, KC_QUOT,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                         KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH,  KC_ESC,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LGUI, TL_LOWR,  KC_SPC,     KC_ENT, TL_UPPR, KC_RALT
                                      //`--------------------------'  `--------------------------'

  ),

  [1] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB,    KC_1,    KC_2,    KC_3,    KC_4,    KC_5,                         KC_6,    KC_7,    KC_8,    KC_9,    KC_0, KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LCTL, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      KC_LEFT, KC_DOWN,   KC_UP,KC_RIGHT, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LGUI, _______,  KC_SPC,     KC_ENT, _______, KC_RALT
                                      //`--------------------------'  `--------------------------'
  ),

  [2] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB, KC_EXLM,   KC_AT, KC_HASH,  KC_DLR, KC_PERC,                      KC_CIRC, KC_AMPR, KC_ASTR, KC_LPRN, KC_RPRN, KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LCTL, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      KC_MINS,  KC_EQL, KC_LBRC, KC_RBRC, KC_BSLS,  KC_GRV,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      KC_UNDS, KC_PLUS, KC_LCBR, KC_RCBR, KC_PIPE, KC_TILD,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LGUI, _______,  KC_SPC,     KC_ENT, _______, KC_RALT
                                      //`--------------------------'  `--------------------------'
  ),

  [3] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
        QK_BOOT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      RGB_TOG, RGB_HUI, RGB_SAI, RGB_VAI, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      RGB_MOD, RGB_HUD, RGB_SAD, RGB_VAD, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LGUI, _______,  KC_SPC,     KC_ENT, _______, KC_RALT
                                      //`--------------------------'  `--------------------------'
  )
};

#ifdef OLED_ENABLE
#include <stdio.h>

/* A tela do Corne e montada com o eixo longo apontando pra longe do usuario.
 * ROTATION_270 deixa as letras em pe, em linhas de 5 caracteres por 16 linhas. */
oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    return OLED_ROTATION_270;
}

/* Nomes com 5 caracteres exatos, que e a largura util da tela. */
static const char *layer_name(void) {
    switch (get_highest_layer(layer_state)) {
        case 0:  return "BASE ";
        case 1:  return "LOWER";
        case 2:  return "RAISE";
        case 3:  return "ADJST";
        default: return "-----";
    }
}

static void render_title(void) {
    oled_write_ln_P(PSTR("CRKBD"), false);
    oled_write_ln_P(PSTR("-----"), false);
}

static void render_layer(void) {
    oled_write_ln_P(PSTR("LAYER"), false);
    oled_write_ln(layer_name(), false);
    oled_write_ln_P(PSTR(""), false);
}

/* WPM numerico + barra de 5 blocos. Cada bloco vale 20 WPM, entao a barra
 * enche em 100 WPM. Blocos "cheios" sao espacos em video invertido, o que
 * dispensa glifos especiais da fonte. */
static void render_wpm(void) {
    char    buf[8];
    uint8_t wpm = get_current_wpm();

    oled_write_ln_P(PSTR(" WPM "), false);
    snprintf(buf, sizeof(buf), " %3d ", wpm);
    oled_write_ln(buf, false);

    uint8_t filled = wpm / 20;
    if (filled > 5) filled = 5;
    for (uint8_t i = 0; i < 5; i++) {
        oled_write_P(PSTR(" "), i < filled);
    }
    oled_write_ln_P(PSTR(""), false);
}

/* Ctrl / Shift / Alt / Gui: letra acesa em video invertido quando ativa. */
static void render_mods(void) {
    uint8_t mods = get_mods() | get_oneshot_mods();

    oled_write_ln_P(PSTR("MODS "), false);
    oled_write_P(PSTR("C"), (mods & MOD_MASK_CTRL)  != 0);
    oled_write_P(PSTR("S"), (mods & MOD_MASK_SHIFT) != 0);
    oled_write_P(PSTR("A"), (mods & MOD_MASK_ALT)   != 0);
    oled_write_P(PSTR("G"), (mods & MOD_MASK_GUI)   != 0);
    oled_write_P(PSTR(" "), false);
    oled_write_ln_P(PSTR(""), false);
}

/* Só ocupa espaco quando ligado, pra nao virar ruido permanente. */
static void render_caps(void) {
    bool caps = host_keyboard_led_state().caps_lock;
    oled_write_ln_P(caps ? PSTR("CAPS ") : PSTR("     "), caps);
}

/* Mesmo conteudo em master e slave: assim a tela e util com o USB em
 * qualquer das metades. Depende dos SPLIT_*_ENABLE do config.h. */
bool oled_task_user(void) {
    render_title();
    render_layer();
    render_wpm();
    render_mods();
    render_caps();
    return false;
}
#endif // OLED_ENABLE
