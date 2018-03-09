package tundra;

import haxe.crypto.Crc32;
import haxe.io.Bytes;
import kha.Font;
import kha.graphics2.Graphics;
import kha.input.KeyCode;
import kha.Color;

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
    public var minLabelWidth:Float = 100.0;
    public var disabled:Bool = false;

    // window position
    public var wx:Float = 0;
    public var wy:Float = 0;
    public var ww:Float = 0;
    public var wh:Float = 0;

    // next control position (global coords)
    private var cx:Float = 0;
    private var cy:Float = 0;
    private var cw:Float = 0;
    private var ch:Float = 0;

    // layout state
    private var labelWidth:Float = 100;
    private var controlWidth:Float = 100;

    // input state
    private var mouseX:Float = -1;
    private var mouseY:Float = -1;
    private var mousePressed:Bool = false;
    private var mouseDown:Bool = false;
    private var mouseReleased:Bool = false;
    private var keyCode:KeyCode = KeyCode.Unknown;
    private var keyChar:String = "";

    private var hotControl:Id = 0;

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

        minLabelWidth = font.width(fontSize, "A decent label");

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

        g.color = theme.panel.bg;
        g.fillRect(wx * scale, wy * scale, ww * scale, wh * scale);
    }

    public function end():Void {
        g.end();

        mousePressed = false;
        mouseReleased = false;
        keyCode = KeyCode.Unknown;
        keyChar = "";
    }

    public function label(label:String, header:Bool=false):Void {
        g.color = theme.label.fg;
        if(header) g.font = boldFont;
        g.drawString(label, (cx + padding) * scale, (cy + padding) * scale);
        if(header) g.font = font;
        advanceCursor();
    }

    public function separator():Void {
        g.color = theme.separator.fg;
        ch *= 0.1;
        g.drawLine(
            (cx + padding) * scale,
            (cy + 0.5 * ch) * scale,
            (cx + cw - 2 * padding) * scale,
            (cy + 0.5 * ch) * scale,
            2.0 * scale
        );
        advanceCursor();
        ch *= 10.0;
    }

    public function button(label:String, ?id:String):Bool {
        var id:Id = GetID(label + "b" + (id == null ? "" : id));

        var hovering:Bool = isHovering();
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
        }

        var fg:Color =
            if(hotControl == id) theme.button.pressed.fg;
            else if(hovering) theme.button.hover.fg;
            else theme.button.normal.fg;
        var bg:Color =
            if(hotControl == id) theme.button.pressed.bg;
            else if(hovering) theme.button.hover.bg;
            else theme.button.normal.bg;
        var border:Color =
            if(hotControl == id) theme.button.pressed.border;
            else if(hovering) theme.button.hover.border;
            else theme.button.normal.border;

        g.color = bg;
        g.fillRect((cx + padding) * scale, cy * scale, (cw - padding - padding) * scale, ch * scale);
        g.color = border;
        g.drawRect((cx + padding) * scale, cy * scale, (cw - padding - padding) * scale, ch * scale, scale);
        g.color = fg;
        g.drawString(label, (cx + padding + 0.5 * (cw - font.width(fontSize, label))) * scale, (cy + padding) * scale);

        advanceCursor();
        var clicked:Bool = hotControl == id && mouseReleased;
        if(clicked) hotControl = 0;
        return clicked;
    }

    public function textInput(text:String, label:String, ?id:String):String {
        var id:Id = GetID(label + "ti" + (id == null ? "" : id));

        var hovering:Bool = isHoveringCustom(cx + padding + labelWidth + padding, cy, controlWidth, ch);
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
            cursorLocation = text.length; // TODO: placement in the string?
        }
        else if(!hovering && mousePressed && hotControl == id) {
            hotControl = 0;
        }

        // logic
        // TODO: implement selections
        if(hotControl == id) {
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
                case KeyCode.Return, KeyCode.Escape: hotControl = 0;
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
        var fg:Color =
            if(hotControl == id) theme.textInput.active.fg;
            else if(hovering) theme.textInput.hover.fg;
            else theme.textInput.normal.fg;
        var bg:Color =
            if(hotControl == id) theme.textInput.active.bg;
            else if(hovering) theme.textInput.hover.bg;
            else theme.textInput.normal.bg;
        var border:Color =
            if(hotControl == id) theme.textInput.active.border;
            else if(hovering) theme.textInput.hover.border;
            else theme.textInput.normal.border;

        g.color = theme.label.fg;
        g.drawString(label, (cx + padding) * scale, (cy + padding) * scale);

        g.color = bg;
        g.fillRect((cx + padding + labelWidth + padding) * scale, cy * scale, (controlWidth - padding - padding) * scale, ch * scale);
        g.color = border;
        g.drawRect((cx + padding + labelWidth + padding) * scale, cy * scale, (controlWidth - padding - padding) * scale, ch * scale, scale);

        g.color = fg;
        g.drawString(text, (cx + padding + labelWidth + padding + padding) * scale, (cy + padding) * scale);

        if(hotControl == id && showTextCursor) {
            var lx:Float = font.width(fontSize, text.substr(0, cursorLocation));
            g.drawLine((cx + padding + labelWidth + padding + padding + lx) * scale, (cy + padding) * scale, (cx + padding + labelWidth + padding + padding + lx) * scale, (cy + ch - padding) * scale, scale);
        }

        advanceCursor();
        return text;
    }

    public function slider(label:String, value:Float, min:Float, max:Float, ?id:String):Float {
        var id:Id = GetID(label + "s" + (id == null ? "" : id));

        // clamp the value
        value = Math.min(Math.max(value, min), max);

        // positioning
        var size:Float = ch - (2 * padding);
        var barLeft:Float = cx + padding + labelWidth;
        var barRight:Float = barLeft + controlWidth - 50 - padding;
        var handleMin:Float = barLeft + padding + (0.5 * size);
        var handleMax:Float = barRight - padding - (0.5 * size);
        var y:Float = (cy + padding + (ch * 0.5));
        var percent:Float = (value - min) / (max - min);
        var x:Float = handleMin + (percent * (handleMax - handleMin));
        
        var hovering:Bool = isHoveringCustom(x - (0.5 * size), y - (0.5 * size), size, size);
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
        }
        else if(hotControl == id && mouseReleased) {
            hotControl = 0;
        }

        // dragging
        if(hotControl == id) {
            percent = ((mouseX / scale) - handleMin) / (handleMax - handleMin);
            percent = Math.min(Math.max(percent, 0.0), 1.0);
            value = min + (percent * (max - min));
            x = handleMin + (percent * (handleMax - handleMin));
        }

        // rendering
        var border:Color =
            if(hotControl == id) theme.slider.pressed.border;
            else if(hovering) theme.slider.hover.border;
            else theme.slider.normal.border;
        var handle:Color =
            if(hotControl == id) theme.slider.pressed.handle;
            else if(hovering) theme.slider.hover.handle;
            else theme.slider.normal.handle;

        g.color = theme.label.fg;
        g.drawString(label, (cx + padding) * scale, (cy + padding) * scale);

        g.color = theme.slider.bar;
        g.drawLine((barLeft + padding) * scale, (cy + padding + (ch * 0.5)) * scale, (barRight - padding) * scale, (cy + padding + (ch * 0.5)) * scale, 4.0 * scale);

        g.color = handle;
        g.fillRect((x - (0.5 * size)) * scale, (y - (0.5 * size)) * scale, size * scale, size * scale);
        g.color = border;
        g.drawRect((x - (0.5 * size)) * scale, (y - (0.5 * size)) * scale, size * scale, size * scale, scale);

        g.color = theme.label.fg;
        var valueString:String = Std.string(Math.fround(value * 100) / 100.0);
        g.drawString(valueString, (cx + cw - padding - font.width(fontSize, valueString)) * scale, (cy + padding) * scale);

        advanceCursor();
        return value;
    }

    public function toggle(value:Bool, label:String, ?id:String):Bool {
        var id:Id = GetID(label + "t" + (id == null ? "" : id));

        var hovering:Bool = isHovering();
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
        }

        var fg:Color =
            if(hotControl == id) theme.button.pressed.fg;
            else if(hovering) theme.button.hover.fg;
            else theme.button.normal.fg;
        var bg:Color =
            if(hotControl == id) theme.button.pressed.bg;
            else if(hovering) theme.button.hover.bg;
            else theme.button.normal.bg;
        var border:Color =
            if(hotControl == id) theme.button.pressed.border;
            else if(hovering) theme.button.hover.border;
            else theme.button.normal.border;

        g.color = theme.label.fg;
        g.drawString(label, (cx + padding) * scale, (cy + padding) * scale);

        g.color = bg;
        g.fillRect((cx + padding + labelWidth + padding) * scale, cy * scale, ch * scale, ch * scale);
        g.color = border;
        g.drawRect((cx + padding + labelWidth + padding) * scale, cy * scale, ch * scale, ch * scale, scale);

        if(value) {
            g.color = fg;
            g.fillRect((cx + padding + labelWidth + padding + padding) * scale, (cy + padding) * scale, (ch - padding - padding) * scale, (ch - padding - padding) * scale);
        }

        advanceCursor();
        var clicked:Bool = hotControl == id && mouseReleased;
        if(clicked) {
            hotControl = 0;
            value = !value;
        }
        return value;
    }

    public function foldOut(open:Bool, label:String, ?id:String):Bool {
        var id:Id = GetID(label + "f" + (id == null ? "" : id));

        var hovering:Bool = isHovering();
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
        }

        var fg:Color =
            if(hotControl == id) theme.button.pressed.fg;
            else if(hovering) theme.button.hover.fg;
            else theme.button.normal.fg;

        g.color = fg;
        var arrowSize:Float = ch - padding - padding;
        if(open) {
            g.fillTriangle(
                (cx + padding) * scale, (cy + padding) * scale,
                (cx + padding + arrowSize) * scale, (cy + padding) * scale,
                (cx + padding + (0.5 * arrowSize)) * scale, (cy + padding + arrowSize) * scale
            );
        }
        else {
            g.fillTriangle(
                (cx + padding) * scale, (cy + padding) * scale,
                (cx + padding + arrowSize) * scale, (cy + padding + (0.5 * arrowSize)) * scale,
                (cx + padding) * scale, (cy + padding + arrowSize) * scale
            );
        }

        g.color = theme.label.fg;
        g.drawString(label, (cx + padding + arrowSize + padding) * scale, (cy + padding) * scale);

        advanceCursor();
        var clicked:Bool = hotControl == id && mouseReleased;
        if(clicked) {
            hotControl = 0;
            open = !open;
        }
        return open;
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
        cw = (ww - (indents * 2.0 * padding)) / columns;
        cx = wx + (indents * 2.0 * padding) + (column * cw);

        labelWidth = Math.max(Math.ffloor(cw / 3.0), minLabelWidth);
        controlWidth = cw - labelWidth - padding;
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

    private inline function isHoveringCustom(x:Float, y:Float, w:Float, h:Float):Bool {
        return
            mouseX >= x * scale && mouseX <= (x + w) * scale &&
            mouseY >= y * scale && mouseY <= (y + h) * scale;
    }

    private function onMouseDown(button:Int, x:Int, y:Int):Void {
		mouseX = x;
        mouseY = y;

        if(button == 0) {
            mousePressed = true;
            mouseDown = true;
        }
    }

	private function onMouseUp(button:Int, x:Int, y:Int):Void {
		mouseX = x;
        mouseY = y;

        if(button == 0) {
            mouseDown = false;
            mouseReleased = true;
        }
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
