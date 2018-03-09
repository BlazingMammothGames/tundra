package tundra;

import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.ds.IntMap;
import kha.graphics2.Graphics;
import kha.input.KeyCode;
import kha.Color;

typedef Id = Int;

class GUI {
    private static var g:Graphics;

    // common parameters
    public static var options:GUIOptions = new GUIOptions();

    // window position
    private static var wx:Float = 0;
    private static var wy:Float = 0;
    private static var ww:Float = 0;
    private static var wh:Float = 0;

    // next control position (global coords)
    private static var cx:Float = 0;
    private static var cy:Float = 0;
    private static var cw:Float = 0;
    private static var ch:Float = 0;

    // layout state
    private static var labelWidth:Float = 100;
    private static var controlWidth:Float = 100;

    // input state
    private static var mouseX:Float = -1;
    private static var mouseY:Float = -1;
    private static var mouseXOffset:Float = 0;
    private static var mouseYOffset:Float = 0;
    private static var mousePressed:Bool = false;
    private static var mouseDown:Bool = false;
    private static var mouseReleased:Bool = false;
    private static var keyCode:KeyCode = KeyCode.Unknown;
    private static var keyChar:String = "";
    private static var lastClickTime:Float = 0.0;

    private static var hotControl:Id = 0;

    // rendering state
    private static var disabled:Bool = false;
    private static var indents:Int = 0;
    private static var column:Int = 0;
    private static var columns:Int = 1;
    private static var showTextCursor:Bool = false;
    private static var cursorLocation:Int = 0;
    private static var lastCursorTime:Float = 0.0;

    private static var currentWindowID:Id = 0;
    private static var windowHeights:IntMap<Float> = new IntMap<Float>();

    public static function hookInputs():Void {
		kha.input.Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
		kha.input.Keyboard.get().notify(onKeyDown, onKeyUp, onKeyPress);
    }

    public static function begin(g2:Graphics):Void {
        g = g2;

        if(kha.System.time - lastCursorTime >= 0.5) {
            showTextCursor = !showTextCursor;
            lastCursorTime = kha.System.time;
        }

        g.begin();

        g.font = options.font;
        g.fontSize = Math.floor(options.fontSize * options.scale);
    }

    public static function end():Void {
        g.end();

        mousePressed = false;
        mouseReleased = false;
        keyCode = KeyCode.Unknown;
        keyChar = "";
    }

    public static function window(rect:GUIWindow, title:String, ?idw:String):GUIWindow {
        var id:Id = GetID(title + "w" + (idw == null ? "" : idw));
        currentWindowID = id;
        if(!windowHeights.exists(currentWindowID)) windowHeights.set(currentWindowID, 0);

        wx = rect.x;
        wy = rect.y;
        ww = rect.w;
        wh = rect.h;

        cx = wx;
        cy = options.padding + wy;
        cw = ww;
        ch = Math.ceil(options.font.height(options.fontSize)) + (2 * options.padding);

        indents = 0;
        column = 0;
        columns = 1;

        var hovering:Bool = isHovering();
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
            mouseXOffset = (mouseX / options.scale) - wx;
            mouseYOffset = (mouseY / options.scale) - wy;
        }

        if(hotControl == id) {
            wx = (mouseX / options.scale) - mouseXOffset;
            wy = (mouseY / options.scale) - mouseYOffset;

            cx = wx;
            cy = options.padding + wy;

            rect.x = wx;
            rect.y = wy;
        }
        
        var fg:Color =
            if(hotControl == id) options.theme.window.pressed.fg;
            else if(hovering) options.theme.window.hover.fg;
            else options.theme.window.normal.fg;
        var bg:Color =
            if(hotControl == id) options.theme.window.pressed.bg;
            else if(hovering) options.theme.window.hover.bg;
            else options.theme.window.normal.bg;
        var border:Color =
            if(hotControl == id) options.theme.window.pressed.border;
            else if(hovering) options.theme.window.hover.border;
            else options.theme.window.normal.border;

        if(rect.open) {
            g.color = options.theme.panel.bg;
            g.fillRect(wx * options.scale, (wy + ch) * options.scale, ww * options.scale, (wh - options.padding - ch) * options.scale);
        }

        g.color = bg;
        g.fillRect(wx * options.scale, wy * options.scale, ww * options.scale, ch * options.scale);
        g.color = border;
        g.drawRect(wx * options.scale, wy * options.scale, ww * options.scale, ch * options.scale, 2.0 * options.scale);
        g.color = fg;
        g.font = options.boldFont;
        g.drawString(title, (wx + options.padding) * options.scale, (wy + options.padding) * options.scale);
        g.font = options.font;

        resizeHandle(title, idw);
        rect.w = ww;
        rect.h = wh;

        if(hotControl == id && mouseReleased) {
            hotControl = 0;
            if(kha.System.time - lastClickTime <= 0.5) {
                // double clicked!
                rect.open = !rect.open;
            }

            lastClickTime = kha.System.time;
        }
        advanceCursor();
        return rect;
    }

    private static function resizeHandle(title:String, ?idw:String):Void {
        var id:Id = GetID(title + "rh" + (idw == null ? "" : idw));
        var hovering:Bool = isHoveringCustom(wx + ww - ch, wy + wh - ch, ch, ch);
        
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
            mouseXOffset = (mouseX / options.scale) - (wx + ww);
            mouseYOffset = (mouseY / options.scale) - (wy + wh);
        }

        if(hotControl == id) {
            ww = (mouseX / options.scale) - wx - mouseXOffset;
            wh = (mouseY / options.scale) - wy - mouseYOffset;

            ww = Math.max(ww, (2.0 * options.minLabelWidth) + options.padding);
        }
        wh = Math.max(wh, windowHeights.get(currentWindowID));
        
        var bg:Color =
            if(hotControl == id) options.theme.window.pressed.bg;
            else if(hovering) options.theme.window.hover.fg;
            else options.theme.window.normal.bg;

        g.color = bg;
        g.fillTriangle(
            (wx + ww - options.padding) * options.scale, (wy + wh - options.padding - ch - options.padding) * options.scale,
            (wx + ww - options.padding) * options.scale, (wy + wh - options.padding - options.padding) * options.scale,
            (wx + ww - options.padding - ch) * options.scale, (wy + wh - options.padding - options.padding) * options.scale
        );

        if(hotControl == id && mouseReleased) {
            hotControl = 0;
        }
    }

    public static function label(label:String, header:Bool=false):Void {
        g.color = options.theme.panel.fg;
        if(header) g.font = options.boldFont;
        g.drawString(label, (cx + options.padding) * options.scale, (cy + options.padding) * options.scale);
        if(header) g.font = options.font;
        advanceCursor();
    }

    public static function separator():Void {
        g.color = options.theme.separator.fg;
        ch *= 0.1;
        g.drawLine(
            (cx + options.padding) * options.scale,
            (cy + 0.5 * ch) * options.scale,
            (cx + cw - 2 * options.padding) * options.scale,
            (cy + 0.5 * ch) * options.scale,
            2.0 * options.scale
        );
        advanceCursor();
        ch *= 10.0;
    }

    public static function button(label:String, ?idb:String):Bool {
        var id:Id = GetID(label + "b" + (idb == null ? "" : idb));

        var hovering:Bool = isHovering();
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
        }

        var fg:Color =
            if(hotControl == id) options.theme.button.pressed.fg;
            else if(hovering) options.theme.button.hover.fg;
            else options.theme.button.normal.fg;
        var bg:Color =
            if(hotControl == id) options.theme.button.pressed.bg;
            else if(hovering) options.theme.button.hover.bg;
            else options.theme.button.normal.bg;
        var border:Color =
            if(hotControl == id) options.theme.button.pressed.border;
            else if(hovering) options.theme.button.hover.border;
            else options.theme.button.normal.border;

        g.color = bg;
        g.fillRect((cx + (4.0 * options.padding)) * options.scale, cy * options.scale, (cw - (8.0 * options.padding)) * options.scale, ch * options.scale);
        g.color = border;
        g.drawRect((cx + (4.0 * options.padding)) * options.scale, cy * options.scale, (cw - (8.0 * options.padding)) * options.scale, ch * options.scale, options.scale);
        g.color = fg;
        g.drawString(label, (cx + options.padding + 0.5 * (cw - options.font.width(options.fontSize, label))) * options.scale, (cy + options.padding) * options.scale);

        advanceCursor();
        var clicked:Bool = hotControl == id && mouseReleased;
        if(clicked) hotControl = 0;
        return clicked;
    }

    public static function textInput(text:String, label:String, ?idt:String):String {
        var id:Id = GetID(label + "ti" + (idt == null ? "" : idt));

        var hovering:Bool = isHoveringCustom(cx + options.padding + labelWidth + options.padding, cy, controlWidth, ch);
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
            if(hotControl == id) options.theme.textInput.active.fg;
            else if(hovering) options.theme.textInput.hover.fg;
            else options.theme.textInput.normal.fg;
        var bg:Color =
            if(hotControl == id) options.theme.textInput.active.bg;
            else if(hovering) options.theme.textInput.hover.bg;
            else options.theme.textInput.normal.bg;
        var border:Color =
            if(hotControl == id) options.theme.textInput.active.border;
            else if(hovering) options.theme.textInput.hover.border;
            else options.theme.textInput.normal.border;

        g.color = options.theme.panel.fg;
        g.drawString(label, (cx + options.padding) * options.scale, (cy + options.padding) * options.scale);

        g.color = bg;
        g.fillRect((cx + options.padding + labelWidth + options.padding) * options.scale, cy * options.scale, (controlWidth - options.padding - options.padding) * options.scale, ch * options.scale);
        g.color = border;
        g.drawRect((cx + options.padding + labelWidth + options.padding) * options.scale, cy * options.scale, (controlWidth - options.padding - options.padding) * options.scale, ch * options.scale, options.scale);

        g.color = fg;
        g.drawString(text, (cx + options.padding + labelWidth + options.padding + options.padding) * options.scale, (cy + options.padding) * options.scale);

        if(hotControl == id && showTextCursor) {
            var lx:Float = options.font.width(options.fontSize, text.substr(0, cursorLocation));
            g.drawLine((cx + options.padding + labelWidth + options.padding + options.padding + lx) * options.scale, (cy + options.padding) * options.scale, (cx + options.padding + labelWidth + options.padding + options.padding + lx) * options.scale, (cy + ch - options.padding) * options.scale, options.scale);
        }

        advanceCursor();
        return text;
    }
    
    public static function intInput(value:Int, label:String, ?idi:String):Int {
        // TODO:
        return value;
    }
    
    public static function floatInput(value:Float, label:String, ?idf:String):Float {
        // TODO:
        return value;
    }

    public static function slider(label:String, value:Float, min:Float, max:Float, ?ids:String):Float {
        var id:Id = GetID(label + "s" + (ids == null ? "" : ids));

        // clamp the value
        value = Math.min(Math.max(value, min), max);

        // positioning
        var size:Float = ch - (2 * options.padding);
        var barLeft:Float = cx + options.padding + labelWidth;
        var barRight:Float = barLeft + controlWidth - 50 - options.padding;
        var handleMin:Float = barLeft + options.padding + (0.5 * size);
        var handleMax:Float = barRight - options.padding - (0.5 * size);
        var y:Float = (cy + options.padding + (ch * 0.5));
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
            percent = ((mouseX / options.scale) - handleMin) / (handleMax - handleMin);
            percent = Math.min(Math.max(percent, 0.0), 1.0);
            value = min + (percent * (max - min));
            x = handleMin + (percent * (handleMax - handleMin));
        }

        // rendering
        var border:Color =
            if(hotControl == id) options.theme.slider.pressed.border;
            else if(hovering) options.theme.slider.hover.border;
            else options.theme.slider.normal.border;
        var handle:Color =
            if(hotControl == id) options.theme.slider.pressed.handle;
            else if(hovering) options.theme.slider.hover.handle;
            else options.theme.slider.normal.handle;

        g.color = options.theme.panel.fg;
        g.drawString(label, (cx + options.padding) * options.scale, (cy + options.padding) * options.scale);

        g.color = options.theme.slider.bar;
        g.drawLine((barLeft + options.padding) * options.scale, (cy + options.padding + (ch * 0.5)) * options.scale, (barRight - options.padding) * options.scale, (cy + options.padding + (ch * 0.5)) * options.scale, 4.0 * options.scale);

        g.color = handle;
        g.fillRect((x - (0.5 * size)) * options.scale, (y - (0.5 * size)) * options.scale, size * options.scale, size * options.scale);
        g.color = border;
        g.drawRect((x - (0.5 * size)) * options.scale, (y - (0.5 * size)) * options.scale, size * options.scale, size * options.scale, options.scale);

        g.color = options.theme.panel.fg;
        var valueString:String = Std.string(Math.fround(value * 100) / 100.0);
        g.drawString(valueString, (cx + cw - options.padding - options.font.width(options.fontSize, valueString)) * options.scale, (cy + options.padding) * options.scale);

        advanceCursor();
        return value;
    }

    public static function toggle(value:Bool, label:String, ?idt:String):Bool {
        var id:Id = GetID(label + "t" + (idt == null ? "" : idt));

        var hovering:Bool = isHovering();
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
        }

        var fg:Color =
            if(hotControl == id) options.theme.button.pressed.fg;
            else if(hovering) options.theme.button.hover.fg;
            else options.theme.button.normal.fg;
        var bg:Color =
            if(hotControl == id) options.theme.button.pressed.bg;
            else if(hovering) options.theme.button.hover.bg;
            else options.theme.button.normal.bg;
        var border:Color =
            if(hotControl == id) options.theme.button.pressed.border;
            else if(hovering) options.theme.button.hover.border;
            else options.theme.button.normal.border;

        g.color = options.theme.panel.fg;
        g.drawString(label, (cx + options.padding) * options.scale, (cy + options.padding) * options.scale);

        g.color = bg;
        g.fillRect((cx + options.padding + labelWidth + options.padding) * options.scale, cy * options.scale, ch * options.scale, ch * options.scale);
        g.color = border;
        g.drawRect((cx + options.padding + labelWidth + options.padding) * options.scale, cy * options.scale, ch * options.scale, ch * options.scale, options.scale);

        if(value) {
            g.color = fg;
            g.fillRect((cx + options.padding + labelWidth + options.padding + options.padding) * options.scale, (cy + options.padding) * options.scale, (ch - options.padding - options.padding) * options.scale, (ch - options.padding - options.padding) * options.scale);
        }

        advanceCursor();
        var clicked:Bool = hotControl == id && mouseReleased;
        if(clicked) {
            hotControl = 0;
            value = !value;
        }
        return value;
    }

    public static function foldOut(open:Bool, label:String, ?idf:String):Bool {
        var id:Id = GetID(label + "f" + (idf == null ? "" : idf));

        var hovering:Bool = isHovering();
        if(hovering && mousePressed && hotControl == 0) {
            hotControl = id;
        }

        var fg:Color =
            if(hotControl == id) options.theme.button.pressed.fg;
            else if(hovering) options.theme.button.hover.fg;
            else options.theme.button.normal.fg;

        g.color = fg;
        var arrowSize:Float = ch - options.padding - options.padding;
        if(open) {
            g.fillTriangle(
                (cx + options.padding) * options.scale, (cy + options.padding) * options.scale,
                (cx + options.padding + arrowSize) * options.scale, (cy + options.padding) * options.scale,
                (cx + options.padding + (0.5 * arrowSize)) * options.scale, (cy + options.padding + arrowSize) * options.scale
            );
        }
        else {
            g.fillTriangle(
                (cx + options.padding) * options.scale, (cy + options.padding) * options.scale,
                (cx + options.padding + arrowSize) * options.scale, (cy + options.padding + (0.5 * arrowSize)) * options.scale,
                (cx + options.padding) * options.scale, (cy + options.padding + arrowSize) * options.scale
            );
        }

        g.color = options.theme.panel.fg;
        g.drawString(label, (cx + options.padding + arrowSize + options.padding) * options.scale, (cy + options.padding) * options.scale);

        advanceCursor();
        var clicked:Bool = hotControl == id && mouseReleased;
        if(clicked) {
            hotControl = 0;
            open = !open;
        }
return open;
    }

    public static function combo(selected:Int, label:String, values:Array<String>, ?idc:String):Int {
        // TODO:
        return selected;
    }

    public static function indent():Void {
        indents++;
        calculateX();
    }

    public static function unindent():Void {
        if(indents > 0) {
            indents--;
            calculateX();
        }
    }

    public static function row(columns:Int):Void {
        column = 0;
        GUI.columns = columns;
        calculateX();
    }

    private inline static function calculateX():Void {
        cw = (ww - (indents * 2.0 * options.padding)) / columns;
        cx = wx + (indents * 2.0 * options.padding) + (column * cw);

        labelWidth = Math.max(Math.ffloor(cw / 3.0), options.minLabelWidth);
        controlWidth = cw - labelWidth - options.padding;
    }

    private inline static function advanceCursor():Void {
        column++;
        if(column >= columns) {
            column = 0;
            columns = 1;
            cy += ch + options.padding;
            windowHeights.set(currentWindowID, cy - wy);
        }
        calculateX();
    }

    private inline static function isHovering():Bool {
        return
            mouseX >= cx * options.scale && mouseX <= (cx + cw) * options.scale &&
            mouseY >= cy * options.scale && mouseY <= (cy + ch) * options.scale;
    }

    private inline static function isHoveringCustom(x:Float, y:Float, w:Float, h:Float):Bool {
        return
            mouseX >= x * options.scale && mouseX <= (x + w) * options.scale &&
            mouseY >= y * options.scale && mouseY <= (y + h) * options.scale;
    }

    private static function onMouseDown(button:Int, x:Int, y:Int):Void {
		mouseX = x;
        mouseY = y;

        if(button == 0) {
            mousePressed = true;
            mouseDown = true;
        }
    }

	private static function onMouseUp(button:Int, x:Int, y:Int):Void {
		mouseX = x;
        mouseY = y;

        if(button == 0) {
            mouseDown = false;
            mouseReleased = true;
        }
    }

	private static function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
		mouseX = x;
        mouseY = y;
	}

	private static function onMouseWheel(delta:Int):Void {
		
	}

	private static function onKeyDown(code:KeyCode):Void {
        keyCode = code;
	}

	private static function onKeyUp(code:KeyCode):Void {

    }

	private static function onKeyPress(char:String):Void {
        keyChar = char;
	}

    private static function GetID(label:String):Id {
        return Crc32.make(Bytes.ofString(label));
    }
}
