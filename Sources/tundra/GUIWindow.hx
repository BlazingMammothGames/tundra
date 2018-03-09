package tundra;

class GUIWindow {
    public var x:Float;
    public var y:Float;
    public var w:Float;
    public var h:Float;
    public var open:Bool;

    public function new(x:Float, y:Float, w:Float, h:Float, open:Bool=true) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.open = open;
    }
}