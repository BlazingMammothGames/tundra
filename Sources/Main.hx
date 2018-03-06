import kha.System;
import kha.Scheduler;

class Main {
    public static function main() {
        Loader.onDone = function():Void {
            Demo.initialize();
            System.notifyOnRender(Demo.render);
            Scheduler.addTimeTask(Demo.update, 0, 1/60);
        };
        System.init({ title: "tundra", width: 800, height: 600}, Loader.load);
    }
}
