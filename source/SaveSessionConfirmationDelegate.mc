using Toybox.WatchUi;

class SaveSessionConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    protected var view;

    public function initialize(view) {
        ConfirmationDelegate.initialize();
        view = view;
    }

    public function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES && gSession != null) {
            gSession.save();
        }

        view.restart();
    }
}
