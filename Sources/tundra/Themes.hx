package tundra;

import kha.Color;

typedef Style = {
    var BACKGROUND:Color;
    var FOREGROUND:Color;
}

typedef Theme = {
    var LABEL:Style;
    var NORMAL:Style;
    var HOVER:Style;
    var ACTIVE:Style;
    var FOCUSED:Style;
}

class Themes {
    public static var dark:Theme = {
        LABEL: {
            BACKGROUND: 0xff383838,
            FOREGROUND: 0xffffffff
        },
        NORMAL: {
            BACKGROUND: 0xffc7c7c7,
            FOREGROUND: 0xff000000
        },
        HOVER: {
            BACKGROUND: 0xff4d4d4d,
            FOREGROUND: 0xffffffff
        },
        ACTIVE: {
            BACKGROUND: 0xff3e5f96,
            FOREGROUND: 0xffffffff
        },
        FOCUSED: {
            BACKGROUND: 0xff000000,
            FOREGROUND: 0xffffffff
        }
    };
}
