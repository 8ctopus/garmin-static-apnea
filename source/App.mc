using Toybox.Application;

class App extends Application.AppBase {
    public function initialize() {
        AppBase.initialize();
    }

    public function getInitialView() {
        var view = new View();
        return [view, new Delegate(view)];
    }
}
