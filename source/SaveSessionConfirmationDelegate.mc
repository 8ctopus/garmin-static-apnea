using Toybox.WatchUi;

class SaveSessionConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    hidden var view;

    function initialize(view) {
        ConfirmationDelegate.initialize();
        view = view;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES && session != null) {
            session.save();
        }

        view.restart();
    }
}
