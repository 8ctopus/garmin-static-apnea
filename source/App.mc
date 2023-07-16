using Toybox.Application;

class App extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var view = new View();
        var delegate = new Delegate(view);
        return [view, delegate];
    }
}
