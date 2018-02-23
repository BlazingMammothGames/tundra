import kha.System;
import kha.Framebuffer;
import kha.Assets;
import zui.Zui;
import zui.Ext;
import zui.Id;

@:allow(Main)
class Tundra {
    static var ui:Zui;

    static function initialize():Void {
        ui = new Zui({ font: Assets.fonts.Inconsolata });
    }

    static function update():Void {
    }

    static function render(fb:Framebuffer):Void {
        fb.g4.begin();
        fb.g4.clear(kha.Color.Black);

        fb.g4.end();

        var g = fb.g2;
		ui.begin(g);
		if(ui.window(Id.handle(), 0, 0, 200, 100, true)) {
			if(ui.button("Hello")) {
				trace("World");
			}
		}
		ui.end();
    }
}
