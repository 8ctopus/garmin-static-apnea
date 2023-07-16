using Toybox.WatchUi;

class SaveSessionConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    protected var view;

    function initialize(view) {
        ConfirmationDelegate.initialize();
        view = view;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES && gSession != null) {
            gSession.save();
        }

        view.restart();
    }
}
