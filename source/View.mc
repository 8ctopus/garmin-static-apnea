using Toybox.ActivityRecording;
using Toybox.Application;
using Toybox.Attention;
using Toybox.FitContributor;
using Toybox.Graphics;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.WatchUi;

class View extends WatchUi.View {
    enum {
        UP = 1,
        DOWN = -1
    }

    protected var timerDirection;

    protected var mode;
    protected var pulse;

    protected var fitField;

    protected var timer = new Timer.Timer();

    public function getDuration(seq) {
        var propName = seq[PROPERTY];

        if (propName == null) {
            return 0;
        }

        // Timer is called 10 times / second.
        // And every time we change the gTime variable.
        // The saved duration is in seconds.
        return Application.getApp().getProperty(propName) * 10;
    }

    public function initialize() {
        restart();
        View.initialize();

        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
    }

    public function restart() {
        gCurrent = 0;
        gTimerIsPaused = true;
        gSession = null;

        timerDirection = DOWN;

        mode = gPhases[0][NAME];

        // gTime is in seconds * 10
        gTime = null;

        fitField = null;

        timer.start(method(:onTimer), 100, true);
    }

    public function pop() {
        WatchUi.popView();
    }

    // Load your resources here
    public function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    public function onSensor(sensorInfo) {
        pulse = sensorInfo.heartRate;
        WatchUi.requestUpdate();
    }

    // ----------- RECORD AND SAVE BEGINNING ------------
    // use the select Start/Stop or touch for recording
    public function startActivityRecording() {
        if (Toybox has :ActivityRecording) {
            // check device for activity recording
            var activityname = WatchUi.loadResource(Rez.Strings.AppName);
            var datafield = WatchUi.loadResource(Rez.Strings.phase);
            var activityphase = activityname + " " + datafield;

            if ((gSession == null) || (gSession.isRecording() == false)) {
                // set up recording session
                gSession = ActivityRecording.createSession({
                    // set session name
                    :name => activityname,
                    // set sport type
                    :sport => ActivityRecording.SPORT_GENERIC,
                    // set sub sport type
                    :subSport => ActivityRecording.SUB_SPORT_GENERIC
                });

                fitField = gSession.createField(
                    activityphase,
                    FIT_FIELD_PHASE_ID,
                    FitContributor.DATA_TYPE_UINT8, {
                        :mesgType => FitContributor.MESG_TYPE_RECORD,
                        :units => datafield
                    }
                );

                fitField.setData(0);
                gSession.start();
            }
        }
    }

    public function stopActivityRecording() {
        if ((gSession != null) && gSession.isRecording()) {
            gSession.stop();
        }
    }

    public function savePhaseInFitField() {
        if (fitField != null) {
            fitField.setData(gCurrent + 1);
        }
    }

    // ----------- RECORD AND SAVE END --------------------
    // ----------- ALARM PROGRAMMING BEGINNING ------------
    public function displayOn() {
        if (Attention has :backlight) {
            Attention.backlight(true);
        }
    }

    public function beepVibrate(dutyCycle, duration) {
        var beepEnabled = Application.getApp().getProperty(ALARM_BEEP_PROP_NAME);
        var vibrateEnabled = Application.getApp().getProperty(ALARM_VIBRATE_PROP_NAME);

        if (beepEnabled) {
            beep();
        }

        if (vibrateEnabled) {
            vibrate(dutyCycle, duration);
        }
    }

    public function beep() {
        if (Attention has :playTone) {
            Attention.playTone(Attention.TONE_LOUD_BEEP);
        }
    }

    public function vibrate(dutyCycle, duration) {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(dutyCycle, duration)]);
        }
    }

    public function doAlarms() {
        var timeInSeconds = gTime / 10;

        // Always turn display on when time is below 10 seconds (independant of alarm property)
        if (timeInSeconds <= 10) {
            displayOn();
        }

        // Wenn beep oder (nicht entweder oder) vibrate aktiviert ist, dann ist der alarm enabled.
        var alarmEnabled = Application.getApp().getProperty(ALARM_BEEP_PROP_NAME) ||
                           Application.getApp().getProperty(ALARM_VIBRATE_PROP_NAME);

        if (!alarmEnabled) {
            return;
        }

        // || is or
        // && is and
        // % means divide by number and take the rest.  Ex: 124 % 25 equals 24      21 % 6 equals 3
        // ! means NOT                != (not equal)
        // == means "is the same"
        // >, <, <=, >=
        // = is not a comparison!
        // a == b ? 1 : 2     means if a equals b then use 1 else use 2

        // ALARM SETINGS BEISTIEL -------------------------------------------------------------------
        //   if (gCurrent == 0 || gCurrent == 2) {
                // For phase 1 (relax-1) and phase 3 (relax-2) only.
                // Note that gCurrent starts with 0

        //        if (timeInSeconds >= 30 && timeInSeconds % 10 == 0) {
                    // display time must be greater equal AND display time divides without "rest" (0 rest) by 10, then:
        //            beep();
        //        }
        //        if (timeInSeconds < 30 && timeInSeconds >= 10 && timeInSeconds % 5 == 0) {
        //            // will vibrate at: 25, 20, 15 and 10 seconds (displayed)
        //            vibrate(25, 1000);
        //        }
        //        if (timeInSeconds <= 5) {
        //            beep();
        //        }
        // ALARM SETINGS BEISTIEL -------------------------------------------------------------------

        // gTime is in seconds * 10
        if (gCurrent == RELAX1 || gCurrent == RELAX2) {
            if (gTime > 300 && gTime % 300 == 0) {
                beepVibrate(50, 250);
            } else if (gTime == 300 || gTime == 300-5 || gTime == 300-10) {
                beepVibrate(50, 250);
            } else if (gTime == 200 || gTime == 200-5) {
                beepVibrate(50, 250);
            } else if (gTime == 100) {
                beepVibrate(50, 250);
            } else if (gTime == 0) {
                // gTime == 0 wird gefragt bevor gTime <= 50 (nächster if block)
                beepVibrate(100, 750);
            } else if (gTime <= 50 && gTime % 10 == 0) {
                // durch else if wird dieser block nicht ausgeführt, wenn gTime == 0
                // alternativ könnte man && gTime > 0 zum if hinzufügen.
                beepVibrate(50, 250);
            }
        }

        if (gCurrent == HYPERVEN) {
            if (gTime == 0) {
                // gTime == 0 wird gefragt bevor gTime <= 50 (nächster if block)
                beepVibrate(100, 750);
            } else if (gTime <= 50 && gTime % 10 == 0) {
                // durch else if wird dieser block nicht ausgeführt, wenn gTime == 0
                // alternativ könnte man && gTime > 0 zum if hinzufügen.
                beepVibrate(50, 250);
            }
        }

        if (gCurrent == STATIK) {
            if (gTime <= 50 && gTime % 10 == 0 && gTime > 0) {
                // 0 wird eh noch vom RELAX2 0er alarmiert.
                beepVibrate(50, 250);
            }
        }
    }

    // ----------- ALARM PROGRAMMING END ------------
    public function onTimer() {
        var lastPhase = gPhases.size() - 1;

        if (gTimerIsPaused) {
            if (gCurrent == lastPhase) {
                // Because we stop the timer here, this is only called once.
                // And only possible if we are already in the last phase (gCurrent == gPhases.size() - 1)
                stopActivityRecording();
                timer.stop();
            }

            return;
        }

        if (gSession == null) {
            startActivityRecording();
            savePhaseInFitField();
        }

        // Only set the gTime when we really start the count down.
        // This is necessary as the menu could possible change the time before we start the count down.
        if (gTime == null) {
            gTime = getDuration(gPhases[0]);
        }

        gTime += timerDirection;

        doAlarms();

        if (gTime == 0 || gTime < 0) {
            gCurrent += 1;
            savePhaseInFitField();

            mode = gPhases[gCurrent][NAME];
            gTime = getDuration(gPhases[gCurrent]);

            if (gCurrent == gPhases.size() - 1) {
                //gCurrent += 1; // invalid but easy to check if we have finished
                savePhaseInFitField();
                timerDirection = UP;
            }
        }

        WatchUi.requestUpdate();
    }

    public function convertTimeToText(timeIn100ms) {
        // Add 9/10 of a second when calculating the timeInS.
        // If for instance a phase has a duration of one second, we want to display 1 for the whole second, before going to 0.
        // This is not true when counting upwards.
        var adjustment = timerDirection == DOWN ? 9 : 0;

        var timeInS = (timeIn100ms + adjustment) / 10;

        var seconds = timeInS % 60;  // % ist Rest von Division

        // %02d bedeutet zwei Stellen mit führender 0
        // https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Lang/Number.html#format-instance_method
        //  x / y ist ganzahlige Division
        return "" + timeInS / 60 + ":" + seconds.format("%02d");
    }

    public function onUpdate(dc) {
        var textField = View.findDrawableById("modeId");
        textField.setText(mode);

        var currentTime = gTime;

        if (currentTime == null) {
            currentTime = getDuration(gPhases[0]);
        }

        var currentTimeText = convertTimeToText(currentTime);

        textField = View.findDrawableById("timeId");
        textField.setText(currentTimeText);

        textField = View.findDrawableById("pulseId");

        var hrPrefix = WatchUi.loadResource(Rez.Strings.heartRatePrefix);

        if (pulse != null && pulse > 0) {
            textField.setText(hrPrefix + " " + pulse);
        } else {
            textField.setText(hrPrefix + " --");
        }

        // call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        //dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_RED);
        //dc.fillRectangle(100, 100, 100, 100);

        //dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        //dc.fillCircle(50, 100, 75);

        //dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_GREEN);
        //dc.drawText(100, 150, Graphics.FONT_NUMBER_THAI_HOT, "123", Graphics.TEXT_JUSTIFY_LEFT);
    }
}
