package tundra;

import kha.Font;
import kha.graphics2.Graphics;

class Tundra {
    private var g:Graphics;

    // window parameters
    public var font:Font = null;
    public var boldFont:Font = null;
    public var padding:Float = 4.0;
    public var fontSize:Int = 10;
    public var title:String = "";
    public var theme:Theme = Themes.dark;
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

    // rendering state
    private var indents:Int = 0;
    private var column:Int = 0;
    private var columns:Int = 1;

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

        g.begin();

        g.font = font;
        g.fontSize = Math.floor(fontSize * scale);

        g.color = theme.LABEL.BACKGROUND;
        g.fillRect(wx * scale, wy * scale, ww * scale, wh * scale);
    }

    public function end():Void {
        g.end();

        mouseReleased = false;
    }

    public function label(text:String, header:Bool=false):Void {
        g.color = theme.LABEL.FOREGROUND;
        if(header) g.font = boldFont;
        g.drawString(text, (cx + padding) * scale, (cy + padding) * scale);
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

    public function button(text:String):Bool {
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
        g.drawString(text, (cx + padding + 0.5 * (cw - font.width(fontSize, text))) * scale, (cy + padding) * scale);

        advanceCursor();
        return hovering && mouseReleased;
    }

    public function indent():Void {
        indents++;
    }

    public function unindent():Void {
        indents--;
        if(indents < 0) indents = 0;
    }

    public function row(columns:Int):Void {
        this.columns = columns + 1;
        calculateX();
    }

    private inline function calculateX():Void {
        cx = wx + (indents * 2.0 * padding);
    }

    private inline function advanceCursor():Void {
        calculateX();
        cy += ch;
    }

    private inline function isHovering():Bool {
        return
            mouseX >= cx * scale && mouseX <= (cx + cw) * scale &&
            mouseY >= cy * scale && mouseY <= (cy + ch) * scale;
    }

    private function onMouseDown(button:Int, x:Int, y:Int):Void {
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

	private function onKeyDown(code:kha.input.KeyCode):Void {
	}

	private function onKeyUp(code:kha.input.KeyCode):Void {

    }

	private function onKeyPress(char:String):Void {

	}
}
