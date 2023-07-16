using Toybox.WatchUi;

class SaveSessionConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    protected var view;

    public function initialize(_view) {
        ConfirmationDelegate.initialize();
        view = _view;
    }

    public function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES && gSession != null) {
            gSession.save();
        }

        view.restart();
    }
}
