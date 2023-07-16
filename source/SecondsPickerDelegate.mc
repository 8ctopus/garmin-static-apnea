using Toybox.Application;
using Toybox.WatchUi;

class SecondsPickerDelegate extends WatchUi.PickerDelegate {
    protected var menuItem;
    protected var propertyName;

    // Eigentlich ist die ID vom menuItem der propertyName.
    // Allerdings wollen wir das irgendwann ändern. Darum geben wir den property namen zusätzlich mit.
    function initialize(_menuItem, _propertyName) {
        PickerDelegate.initialize();
        menuItem = _menuItem;
        propertyName = _propertyName;
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onAccept(values) {
        var timeInSeconds = values[0] * 60 + values[2];
        Application.getApp().setProperty(propertyName, timeInSeconds);

        // Nachdem wir jetzt eine neue Zeit haben, muss das Sublabel vom Menüpunkt angepasst werden.
        // TODO minutes:seconds formatting in eine Funktion bringen.
        var minutes = timeInSeconds / 60;

        // %02d bedeutet zwei Stellen mit führender 0
        // https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Lang/Number.html#format-instance_method
        var seconds = timeInSeconds % 60;

        // Wir starten mit einem leeren String, damit der Compiler für das + in den Textmodus springt.
        var subLabel = minutes + ":" + seconds.format("%02d");
        menuItem.setSubLabel(subLabel);

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
