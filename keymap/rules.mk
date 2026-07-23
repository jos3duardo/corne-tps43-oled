# Controlador: RP2040 Pro Micro generico (RP2040 Community Edition)
CONVERT_TO          = rp2040_ce

VIA_ENABLE          = yes
VIAL_ENABLE         = yes
LTO_ENABLE          = yes

RGBLIGHT_ENABLE     = yes
RGB_MATRIX_ENABLE   = no # Can't have RGBLIGHT and RGB_MATRIX at the same time.
MOUSEKEY_ENABLE     = yes

POINTING_DEVICE_ENABLE = yes
POINTING_DEVICE_DRIVER = azoteq_iqs5xx
OLED_ENABLE         = yes
OLED_DRIVER         = ssd1306
WPM_ENABLE          = yes
EXTRAKEY_ENABLE     = no
COMBO_ENABLE        = no

QMK_SETTINGS        = no

CAPS_WORD_ENABLE = no
LAYER_LOCK_ENABLE = no
REPEAT_KEY_ENABLE = no
