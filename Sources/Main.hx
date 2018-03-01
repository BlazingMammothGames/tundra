import kha.System;
import kha.Scheduler;

class Main {
    public static function main() {
        Loader.onDone = function():Void {
            Tundra.initialize();
            System.notifyOnRender(Tundra.render);
            Scheduler.addTimeTask(Tundra.update, 0, 1/60);
        };
        System.init({ title: "tundra", width: 800, height: 600}, Loader.load);
    }
}
