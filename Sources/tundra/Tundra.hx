package tundra;

import haxe.crypto.Crc32;
import haxe.io.Bytes;
import kha.Font;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

typedef Id = Int;

class Tundra {
    private var g:Graphics;

    // window parameters
    public var font:Font = null;
    public var boldFont:Font = null;
    public var padding:Float = 4.0;
    public var fontSize:Int = 12;
    public var title:String = "";
    public var theme:Themes.Theme = Themes.dark;
    public var scale:Float = 1.0;

    // window position
    public var wx:Float = 0;
    public var wy:Float = 0;
    public var ww:Float = 0;
    public var wh:Float = 0;

    // next control position
    private var cx:Float = 0;
    private var cy:Float = 0;
    private var cw:Float = 0;
    private var ch:Float = 0;

    // input state
    private var mouseX:Float = -1;
    private var mouseY:Float = -1;
    private var mouseDown:Bool = false;
    private var mouseReleased:Bool = false;
    private var keyCode:KeyCode = KeyCode.Unknown;
    private var keyChar:String = "";

    private var focused:Id = -1;

    // rendering state
    private var indents:Int = 0;
    private var column:Int = 0;
    private var columns:Int = 1;
    private var showTextCursor:Bool = false;
    private var cursorLocation:Int = 0;
    private var lastCursorTime:Float = 0.0;

    public function new(font:Font, boldFont:Font) {
        this.font = font;
        this.boldFont = boldFont;

        #if kha_webgl
        scale = js.Browser.window.devicePixelRatio;
        #end

		kha.input.Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
		kha.input.Keyboard.get().notify(onKeyDown, onKeyUp, onKeyPress);
    }

    public function begin(g2:Graphics):Void {
        g = g2;

        cx = wx;
        cy = padding + wy;
        cw = ww;
        ch = Math.ceil(font.height(fontSize)) + (2 * padding);

        indents = 0;
        column = 0;
        columns = 1;

        if(kha.System.time - lastCursorTime >= 0.5) {
            showTextCursor = !showTextCursor;
            lastCursorTime = kha.System.time;
        }

        g.begin();

        g.font = font;
        g.fontSize = Math.floor(fontSize * scale);

        g.color = theme.LABEL.BACKGROUND;
        g.fillRect(wx * scale, wy * scale, ww * scale, wh * scale);
    }

    public function end():Void {
        g.end();

        mouseReleased = false;
        keyCode = KeyCode.Unknown;
        keyChar = "";
    }

    public function label(label:String, header:Bool=false):Void {
        g.color = theme.LABEL.FOREGROUND;
        if(header) g.font = boldFont;
        g.drawString(label, (cx + padding) * scale, (cy + padding) * scale);
        if(header) g.font = font;
        advanceCursor();
    }

    public function separator():Void {
        g.color = theme.LABEL.FOREGROUND;
        ch *= 0.5;
        g.drawLine(
            (cx + padding) * scale,
            (cy + 0.5 * ch) * scale,
            (cx + cw - 2 * padding) * scale,
            (cy + 0.5 * ch) * scale,
            2.0
        );
        advanceCursor();
        ch *= 2.0;
    }

    public function button(label:String):Bool {
        var hovering:Bool = isHovering();
        g.color =
            if(hovering && mouseReleased) theme.FOCUSED.BACKGROUND;
            else if(hovering && mouseDown) theme.ACTIVE.BACKGROUND;
            else if(hovering) theme.HOVER.BACKGROUND;
            else theme.NORMAL.BACKGROUND;
        g.fillRect(cx * scale, cy * scale, cw * scale, ch * scale);
        g.color =
            if(hovering && mouseReleased) theme.FOCUSED.FOREGROUND;
            else if(hovering && mouseDown) theme.ACTIVE.FOREGROUND;
            else if(hovering) theme.HOVER.FOREGROUND;
            else theme.NORMAL.FOREGROUND;
        g.drawString(label, (cx + padding + 0.5 * (cw - font.width(fontSize, label))) * scale, (cy + padding) * scale);

        advanceCursor();
        return hovering && mouseReleased;
    }

    public function textInput(label:String, text:String):String {
        var id:Id = GetID(label);
        while(StringTools.startsWith(label, '#')) label = label.substr(1);

        var hovering:Bool = isHovering();
        if(hovering && mouseReleased) {
            focused = id;
            cursorLocation = text.length; // TODO: placement in the string?
        }

        // logic
        // TODO: implement selections
        if(focused == id) {
            switch(keyCode) {
                case KeyCode.Left: if(cursorLocation > 0) cursorLocation--;
                case KeyCode.Right: cursorLocation++;
                case KeyCode.Backspace: {
                    if(cursorLocation > 0) {
                        text = text.substr(0, cursorLocation - 1) + text.substr(cursorLocation);
                        cursorLocation--;
                    }
                }
                case KeyCode.Delete: {
                    if(cursorLocation < text.length) {
                        text = text.substr(0, cursorLocation) + text.substr(cursorLocation + 1);
                    }
                }
                case KeyCode.Home: cursorLocation = 0;
                case KeyCode.End: cursorLocation = text.length;
                case KeyCode.Return: focused = -1;
                default: {}
            }

            if(keyChar != "") {
                text = text.substr(0, cursorLocation) + keyChar + text.substr(cursorLocation);
                cursorLocation++;
            }

            if(cursorLocation > text.length) {
                cursorLocation = text.length;
            }
        }

        // rendering
        g.color =
            if(focused == id) theme.ACTIVE.BACKGROUND;
            else if(hovering) theme.HOVER.BACKGROUND;
            else theme.NORMAL.BACKGROUND;
        g.fillRect(cx * scale, cy * scale, cw * scale, ch * scale);
        g.color =
            if(focused == id) theme.ACTIVE.FOREGROUND;
            else if(hovering) theme.HOVER.FOREGROUND;
            else theme.NORMAL.FOREGROUND;
        g.drawString(text, (cx + padding) * scale, (cy + padding) * scale);
        g.drawString(label, (cx + cw - padding - font.width(fontSize, label)) * scale, (cy + padding) * scale);

        if(focused == id && showTextCursor) {
            var lx:Float = font.width(fontSize, text.substr(0, cursorLocation));
            g.drawLine((cx + padding + lx) * scale, (cy + padding) * scale, (cx + padding + lx) * scale, (cy + ch - padding) * scale);
        }

        advanceCursor();
        return text;
    }

    public function indent():Void {
        indents++;
        calculateX();
    }

    public function unindent():Void {
        if(indents > 0) {
            indents--;
            calculateX();
        }
    }

    public function row(columns:Int):Void {
        column = 0;
        this.columns = columns;
        calculateX();
    }

    private inline function calculateX():Void {
        cw = (ww - (indents * 2.0 * padding) - (padding * (columns - 1))) / columns;
        cx = wx + (indents * 2.0 * padding) + (column * (cw + padding));
    }

    private inline function advanceCursor():Void {
        column++;
        if(column >= columns) {
            column = 0;
            columns = 1;
            cy += ch + padding;
        }
        calculateX();
    }

    private inline function isHovering():Bool {
        return
            mouseX >= cx * scale && mouseX <= (cx + cw) * scale &&
            mouseY >= cy * scale && mouseY <= (cy + ch) * scale;
    }

    private function onMouseDown(button:Int, x:Int, y:Int):Void {
        focused = -1;
		mouseX = x;
        mouseY = y;
        mouseDown = true;
    }

	private function onMouseUp(button:Int, x:Int, y:Int):Void {
		mouseX = x;
        mouseY = y;
        mouseDown = false;
        mouseReleased = true;
    }

	private function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
		mouseX = x;
        mouseY = y;
	}

	private function onMouseWheel(delta:Int):Void {
		
	}

	private function onKeyDown(code:KeyCode):Void {
        keyCode = code;
	}

	private function onKeyUp(code:KeyCode):Void {

    }

	private function onKeyPress(char:String):Void {
        keyChar = char;
	}

    private function GetID(label:String):Id {
        return Crc32.make(Bytes.ofString(label));
    }
}
