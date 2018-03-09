import kha.System;
import kha.Framebuffer;
import kha.Assets;
/*import zui.Zui;
import zui.Id;

using CustomZUI;*/
import tundra.Tundra;

@:allow(Main)
class Demo {
    //static var ui:Zui;
    static var ui:Tundra;

    static function initialize():Void {
        /*ui = new Zui({
            font: Assets.fonts.Inconsolata,
            #if kha_html5
            scaleFactor: js.Browser.window.devicePixelRatio
            #end
        });*/
        ui = new Tundra(Assets.fonts.Inconsolata, Assets.fonts.Inconsolata_Bold);
        ui.ww = 200;
        ui.wh = 400;
    }

    static function update():Void {
    }

    /*static var showPlayer:Bool = false;
    static var selected:Int = -1;*/
    static var name:String = "Goat";
    static var quote:String = "I like cheese";
    static var sliderValue:Float = 50;

    static function render(fb:Framebuffer):Void {
        fb.g4.begin();
        fb.g4.clear(kha.Color.Black);

        fb.g4.end();

        // ZUI
		/*var g = fb.g2;
        ui.begin(g);
		if(ui.window(Id.handle(), 0, 0, 299, System.windowHeight(), false)) {
            ui.text("Hierarchy", Align.Center);
            ui.separator();
            selected = -1;
            var h = ui.hierarchy(Id.handle(), "Player", true);
            if(h.selected) selected = 0;
            if(h.expanded) {
                ui.indent();
                var c = ui.hierarchy(Id.handle(), "Camera", false);
                if(c.selected) selected = 1;
                ui.unindent();
            }
		}
        if(ui.window(Id.handle(), Std.int(300 * js.Browser.window.devicePixelRatio), 0, 300, System.windowHeight(), false)) {
            ui.text("Inspector", Align.Center);
            ui.separator();
            switch(selected) {
                default: {}
                case 0: {
                    ui.text("Player", Align.Left);
                    if(ui.panel(Id.handle(), "Transform")) {
                        ui.row([0.33, 0.33, 0.34]);
                        ui.floatInput(Id.handle({ text: "0.0" }), "x");
                        ui.floatInput(Id.handle({ text: "0.0" }), "y");
                        ui.floatInput(Id.handle({ text: "0.0" }), "z");
                    }
                    if(ui.panel(Id.handle(), "Health")) {
                        ui.slider(Id.handle({ value: 100 }), "health", 0, 100, true, 100, true);
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
		ui.end();*/

        ui.begin(fb.g2);
        ui.label("Header", true);
        ui.separator();
        ui.label("Label");
        if(ui.button("Click me")) {
            js.Browser.console.log('Click me clicked!');
        }
        ui.indent();
            ui.label("Indented");
            ui.indent();
                ui.label("Double indented");
            ui.unindent();
        ui.unindent();
        name = ui.textInput("name", name);
        quote = ui.textInput("quote", quote);

        ui.row(2);
        if(ui.button("A")) js.Browser.console.log('A clicked!');
        if(ui.button("B")) js.Browser.console.log('B clicked!');
        sliderValue = ui.slider("Slider", sliderValue, 0, 100);
        
        ui.end();
    }
}
