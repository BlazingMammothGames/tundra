import kha.System;
import kha.Framebuffer;
import kha.Assets;
import zui.Zui;
import zui.Id;

using CustomUI;

@:allow(Main)
class Tundra {
    static var ui:Zui;

    static function initialize():Void {
        ui = new Zui({
            font: Assets.fonts.Inconsolata,
            #if kha_html5
            scaleFactor: js.Browser.window.devicePixelRatio
            #end
        });
    }

    static function update():Void {
    }

    static var showPlayer:Bool = false;
    static var selected:Int = -1;

    static function render(fb:Framebuffer):Void {
        fb.g4.begin();
        fb.g4.clear(kha.Color.Black);

        fb.g4.end();

        var g = fb.g2;
		ui.begin(g);
		if(ui.window(Id.handle(), 0, 0, 299, System.windowHeight(), false)) {
            ui.text("Hierarchy", Align.Center);
            ui.separator();
            /*ui.row([0.1, 0.9]);
            if(ui.button(showPlayer ? "v" : ">")) {
                showPlayer = !showPlayer;
            }
            if(ui.button("Player", Align.Left)) {
                selected = 0;
            }
            if(showPlayer) {
                ui.indent();
                ui.row([0.1, 0.9]);
                //ui.button("");
                ui.text("");
                if(ui.button("Camera", Align.Left)) {
                    selected = 1;
                }
                ui.unindent();
            }*/

            var ph = Id.handle();
            if(ui.hierarchy(ph, "Player", true)) {
                ui.indent();

                var ch = Id.handle();
                ui.hierarchy(ch, "Camera");
                if(ch.changed) selected = 1;

                ui.unindent();
            }
            if(ph.changed) {
                selected = 0;
            }
		}
        if(ui.window(Id.handle(), 300, 0, 300, System.windowHeight(), false)) {
            ui.text("Inspector", Align.Center);
            ui.separator();
            switch(selected) {
                default: {}
                case 0: {
                    ui.text("Player", Align.Left);
                    if(ui.panel(Id.handle(), "Transform")) {
                        ui.row([0.33, 0.33, 0.34]);
                        ui.floatInput(Id.handle({ value: 0.0 }), "x");
                        ui.floatInput(Id.handle({ value: 0.0 }), "y");
                        ui.floatInput(Id.handle({ value: 0.0 }), "z");
                    }
                    if(ui.panel(Id.handle(), "Health")) {
                        ui.slider(Id.handle(), "health", 0, 100, true, 100, true);
                    }
                }

                case 1: {
                    ui.text("Camera", Align.Left);
                    if(ui.panel(Id.handle(), "Camera")) {
                        ui.row([0.5, 0.5]);
                        ui.floatInput(Id.handle(), "zNear");
                        ui.floatInput(Id.handle(), "zFar");
                    }
                }
            }
        }
		ui.end();
    }
}
