using Toybox.WatchUi;

class Delegate extends WatchUi.BehaviorDelegate {
    hidden const KEY_START_STOP = WatchUi.KEY_ENTER;
    hidden const KEY_NEXT_PHASE = WatchUi.KEY_DOWN;

    hidden var apnoeView;

    function initialize(_apnoeView) {
        BehaviorDelegate.initialize();
        apnoeView = _apnoeView;
    }

    function isLastPhase() {
        return (gCurrent + 1) >= gSequence.size();
    }

    function onBack() {
        if (isLastPhase() && gTimerIsPaused) {
            askSaveSession();

            // don't do anything else.
            return true;
        } else if (isLastPhase() && !gTimerIsPaused) {
            // simply stop timer -- don't do anything else.
            gTimerIsPaused = !gTimerIsPaused;

            // don't do anything else.
            return true;
        }

        return false;
    }

    function onKey(evt) {
        if (evt.getKey() != KEY_START_STOP && evt.getKey() != KEY_NEXT_PHASE) {
            return false;
        }

        if (evt.getType() != WatchUi.PRESS_TYPE_ACTION) {
            return true;
        }

        // KEY_START_STOP is the constant defined at the top of this file.
        if (evt.getKey() == KEY_START_STOP) {
            if (isLastPhase() && gTimerIsPaused) {
                askSaveSession();
            } else {
                gTimerIsPaused = !gTimerIsPaused;
            }
        } else if (evt.getKey() == KEY_NEXT_PHASE) {
            if (gCurrent < gSequence.size() - 1) {
                gTime = 1;
            }
        }

        return true;
    }

    function askSaveSession() {
        // session should never be null, unless the watch has a problem (out of disk-space?)
        if (gSession == null) {
            return;
        }

        var message = WatchUi.loadResource(Rez.Strings.saveActivityQuestion);
        var view = new WatchUi.Confirmation(message);
        var delegate = new SaveSessionConfirmationDelegate(apnoeView);
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_UP);
    }

    // When a menu behavior occurs, onMenu() is called.
    // @return [Boolean] true if handled, false otherwise
    function onMenu() {
        var titletext = WatchUi.loadResource(Rez.Strings.settingmenutitel);
        var menu = new WatchUi.Menu2({:title=> titletext});
        //var delegate;

        var options = {};

        // Schleife um über alle Einträge in der gSequence variable.
        for (var i = 0; i < gSequence.size(); i++) {
            // - 1 weil Statik keinen gespeicherten Zahlenwert hat.
            // Dieser Code wird der Reihe nach für RELAX1, HYPERVEN, RELAX2, STATIK ausgeführt.
            var phase = gSequence[i];

            if (phase[PROPERTY] == null) {
            // Für diese Phase gibt es keinen Zahlenwert zu speicher (z.B. Statik).
            continue;
            }

            var label = phase[NAME];
            var savedSeconds = Application.getApp().getProperty(phase[PROPERTY]);

            var minutes = savedSeconds / 60;

            // %02d bedeutet zwei Stellen mit führender 0
            // https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Lang/Number.html#format-instance_method
            var seconds = savedSeconds % 60;

            // Wir starten mit einem leeren String, damit der Compiler für das + in den Textmodus springt.
            var subLabel = "" + minutes + ":" + seconds.format("%02d");
            var id = phase[PROPERTY];

            var menuItem = new WatchUi.MenuItem(label, subLabel, id, options);
            menu.addItem(menuItem);
        }

        var labelVibrate = WatchUi.loadResource(Rez.Strings.alarm_vibrate);
        var subLabelVibrate = WatchUi.loadResource(Rez.Strings.alarmOnOff);
        var idVibrate = ALARM_VIBRATE_PROP_NAME;
        var vibrateCurrentlyEnabled = Application.getApp().getProperty(ALARM_VIBRATE_PROP_NAME);
        var vibrateMenuItem = new WatchUi.ToggleMenuItem(labelVibrate, subLabelVibrate, idVibrate, vibrateCurrentlyEnabled, options);
        menu.addItem(vibrateMenuItem);

        var labelBeep = WatchUi.loadResource(Rez.Strings.alarm_beep);
        var subLabelBeep = WatchUi.loadResource(Rez.Strings.alarmOnOff);
        var idBeep = ALARM_BEEP_PROP_NAME;
        var beepCurrentlyEnabled = Application.getApp().getProperty(ALARM_BEEP_PROP_NAME);
        var beepMenuItem = new WatchUi.ToggleMenuItem(labelBeep, subLabelBeep, idBeep, beepCurrentlyEnabled, options);
        menu.addItem(beepMenuItem);

        WatchUi.pushView(menu, new MenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
}
