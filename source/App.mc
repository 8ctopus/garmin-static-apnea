using Toybox.Application;

class App extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var view = new View();
        return [view, new Delegate(view)];
    }
}
