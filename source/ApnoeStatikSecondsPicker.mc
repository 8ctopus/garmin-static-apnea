using Toybox.Graphics;
using Toybox.WatchUi;

class SecondsPicker extends WatchUi.Picker {

    function initialize(defaultSeconds, title) {
        var factories = [
            new NumberFactory(0, 59, 1, {}),
            new WatchUi.Text({:text  => ":",
                              :font  => Graphics.FONT_NUMBER_HOT,
                              :locX  => WatchUi.LAYOUT_HALIGN_CENTER,
                              :locY  => WatchUi.LAYOUT_VALIGN_CENTER,
                              :color => Graphics.COLOR_WHITE}),
            new NumberFactory(0, 59, 1, {})
        ];

        var titleDrawable = new WatchUi.Text({:text  => title,
                                              :font  => Graphics.FONT_MEDIUM,
                                              :locX  => WatchUi.LAYOUT_HALIGN_CENTER,
                                              :locY  => WatchUi.LAYOUT_VALIGN_CENTER,
                                              :color => Graphics.COLOR_WHITE});

        var defaults = [defaultSeconds / 60, 0, defaultSeconds % 60];
        Picker.initialize({:pattern=>factories,
                           :defaults=>defaults,
                           :title=>titleDrawable});
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}
