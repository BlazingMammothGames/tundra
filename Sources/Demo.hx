import kha.Framebuffer;
import kha.Assets;
import tundra.GUI;
import tundra.GUIWindow;

@:allow(Main)
class Demo {
    static function initialize():Void {
        GUI.options.font = Assets.fonts.Inconsolata;
        GUI.options.boldFont = Assets.fonts.Inconsolata_Bold;

        GUI.hookInputs();
    }

    static function update():Void {
    }

    static var window:GUIWindow = new GUIWindow(10, 10, 300, 400);
    static var name:String = "Goat";
    static var quote:String = "I like cheese";
    static var sliderValue:Float = 50;
    static var checked:Bool = false;
    static var open:Bool = false;

    static function render(fb:Framebuffer):Void {
        fb.g4.begin();
        fb.g4.clear(kha.Color.Black);

        fb.g4.end();

        GUI.begin(fb.g2);
        window = GUI.window(window, "Inspector");
        if(window.open) {
            GUI.label("Header", true);
            GUI.separator();
            GUI.label("Label");
            if(GUI.button("Click me")) {
                js.Browser.console.log('Click me clicked!');
            }
            GUI.indent();
                GUI.label("Indented");
                GUI.indent();
                    GUI.label("Double indented");
                GUI.unindent();
            GUI.unindent();
            name = GUI.textInput(name, "Player name:");
            quote = GUI.textInput(quote, "Quote:");

            GUI.row(2);
            if(GUI.button("Column A")) js.Browser.console.log('A clicked!');
            if(GUI.button("Column B")) js.Browser.console.log('B clicked!');
            sliderValue = GUI.slider("Slider", sliderValue, 0, 100);
            checked = GUI.toggle(checked, "Toggle me!");
            open = GUI.foldOut(open, "Open me!");
            if(open) {
                GUI.indent();
                GUI.label("I'm in a foldout!");
                GUI.unindent();
            }
            GUI.label("I'm not in a foldout!");
        }
        GUI.end();
    }
}
