package tundra;

import kha.Font;

class GUIOptions {
    public var font:Font = null;
    public var boldFont:Font = null;
    public var padding:Float = 4.0;
    public var fontSize:Int = 16;
    public var theme:Themes.Theme;
    public var scale:Float = {
        #if kha_webgl
        js.Browser.window.devicePixelRatio;
        #else
        1.0;
        #end
    };
    public var minLabelWidth:Float = 100.0;

    public function new() {
        theme = Themes.dark;
    }
}