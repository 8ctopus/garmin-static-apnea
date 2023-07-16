using Toybox.WatchUi;

class MenuDelegate extends WatchUi.Menu2InputDelegate {
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(menuItem) {
        // item.id is the propertyName of the saved seconds.
        var propertyName = menuItem.getId();

        if (propertyName == ALARM_VIBRATE_PROP_NAME || propertyName == ALARM_BEEP_PROP_NAME) {
            Application.getApp().setProperty(propertyName, menuItem.isEnabled());
            return true;
        }

        var title = propertyName;

        // extract title using property name
        for (var i = 0; i < gPhases.size(); i++) {
            var phase = gPhases[i];

            if (phase[PROPERTY] == propertyName) {
                title = WatchUi.loadResource(phase[NAME]);
                break;
            }
        }

        // retrieve them and provide them as default value for SecondsPicker
        var savedSeconds = Application.getApp().getProperty(propertyName);
        var secondsPicker = new SecondsPicker(savedSeconds, title);

        // also give the delegate the name of the property, so that it can save the new value
        var delegate = new SecondsPickerDelegate(menuItem, propertyName);

        WatchUi.pushView(secondsPicker, delegate, WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
