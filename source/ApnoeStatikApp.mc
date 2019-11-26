using Toybox.Application;


class ApnoeStatikApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Return the initial view of your application here
    function getInitialView() {
        var apnoeView = new ApnoeStatikView();
        var apnoeDelegate = new ApnoeStatikDelegate(apnoeView);
        return [ apnoeView , apnoeDelegate ];
    }
}
