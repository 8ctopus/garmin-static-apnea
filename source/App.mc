using Toybox.Application;

class ApnoeStatikApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var apnoeView = new ApnoeStatikView();
        var apnoeDelegate = new ApnoeStatikDelegate(apnoeView);
        return [ apnoeView , apnoeDelegate ];
    }
}
