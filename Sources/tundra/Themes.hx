package tundra;

import kha.Color;

// TODO: disabled styles
typedef Theme = {
    panel: {
        bg: Color
    },
    label: {
        fg: Color
    },
    separator: {
        fg: Color
    },
    button: {
        normal: {
            bg: Color,
            fg: Color,
            border: Color
        },
        hover: {
            bg: Color,
            fg: Color,
            border: Color
        },
        pressed: {
            bg: Color,
            fg: Color,
            border: Color
        }
    },
    textInput: {
        normal: {
            bg: Color,
            fg: Color,
            border: Color
        },
        hover: {
            bg: Color,
            fg: Color,
            border: Color
        },
        active: {
            bg: Color,
            fg: Color,
            border: Color
        }
    },
    slider: {
        bar: Color,
        normal: {
            border: Color,
            handle: Color
        },
        hover: {
            border: Color,
            handle: Color
        },
        pressed: {
            border: Color,
            handle: Color
        }
    }
}

class Themes {
    public static var dark:Theme = {
        panel: {
            bg: 0xff383838
        },
        label: {
            fg: 0xffffffff
        },
        separator: {
            fg: 0xff4d4d4d
        },
        button: {
            normal: {
                bg: 0xff545454,
                fg: 0xffffffff,
                border: 0xffcccccc
            },
            hover: {
                bg: 0xff545454,
                fg: 0xffffffff,
                border: 0xffffffff
            },
            pressed: {
                bg: 0xff3e5f96,
                fg: 0xffffffff,
                border: 0xff3e5f96
            }
        },
        textInput: {
            normal: {
                bg: 0xff414141,
                fg: 0xffffffff,
                border: 0xff000000
            },
            hover: {
                bg: 0xff414141,
                fg: 0xffffffff,
                border: 0xffffffff
            },
            active: {
                bg: 0xff3e5f96,
                fg: 0xffffffff,
                border: 0xff3e5f96
            }
        },
        slider: {
            bar: 0xff414141,
            normal: {
                border: 0xffcccccc,
                handle: 0xff545454
            },
            hover: {
                border: 0xffffffff,
                handle: 0xff545454
            },
            pressed: {
                border: 0xff3e5f96,
                handle: 0xff3e5f96
            }
        }
    };
}
