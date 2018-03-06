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