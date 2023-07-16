using Toybox.Graphics;
using Toybox.WatchUi;

class NumberFactory extends WatchUi.PickerFactory {
    protected var mStart;
    protected var mStop;
    protected var mIncrement;
    protected var mFormatString;
    protected var mFont;

    public function getIndex(value) {
        var index = (value / mIncrement) - mStart;
        return index;
    }

    public function initialize(start, stop, increment, options) {
        PickerFactory.initialize();

        mStart = start;
        mStop = stop;
        mIncrement = increment;

        if (options != null) {
            // mFormatString = options.get(:format);
            mFont = options.get(:font);
        }

        if (mFont == null) {
            mFont = Graphics.FONT_NUMBER_HOT;
        }

        // numbers must be in 2 digits with leading zero
        mFormatString = "%02d";
    }

    public function getDrawable(index, selected) {
        return new WatchUi.Text({
            :text => getValue(index).format(mFormatString),
            :color => Graphics.COLOR_WHITE,
            :font => mFont,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    public function getValue(index) {
        return mStart + (index * mIncrement);
    }

    public function getSize() {
        return ( mStop - mStart ) / mIncrement + 1;
    }
}
