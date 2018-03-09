import kha.Framebuffer;
import kha.Assets;
import tundra.Tundra;

@:allow(Main)
class Demo {
    static var ui:Tundra;

    static function initialize():Void {
        ui = new Tundra(Assets.fonts.Inconsolata, Assets.fonts.Inconsolata_Bold);
        ui.ww = 300;
        ui.wh = 400;
    }

    static function update():Void {
    }

    static var name:String = "Goat";
    static var quote:String = "I like cheese";
    static var sliderValue:Float = 50;
    static var checked:Bool = false;
    static var open:Bool = false;

    static function render(fb:Framebuffer):Void {
        fb.g4.begin();
        fb.g4.clear(kha.Color.Black);

        fb.g4.end();

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
        name = ui.textInput(name, "Player name:");
        quote = ui.textInput(quote, "Quote:");

        ui.row(2);
        if(ui.button("Column A")) js.Browser.console.log('A clicked!');
        if(ui.button("Column B")) js.Browser.console.log('B clicked!');
        sliderValue = ui.slider("Slider", sliderValue, 0, 100);
        checked = ui.toggle(checked, "Toggle me!");
        open = ui.foldOut(open, "Open me!");
        if(open) {
            ui.indent();
            ui.label("I'm in a foldout!");
            ui.unindent();
        }
        ui.label("I'm not in a foldout!");
        
        ui.end();
    }
}
