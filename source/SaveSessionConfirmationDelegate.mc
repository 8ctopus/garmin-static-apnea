using Toybox.WatchUi;

class SaveSessionConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    hidden var apnoeView;

    function initialize(_apnoeView) {
        ConfirmationDelegate.initialize();
        apnoeView = _apnoeView;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES && session != null) {
            session.save();                                      // save the session
        }

        apnoeView.restart();
    }

}
