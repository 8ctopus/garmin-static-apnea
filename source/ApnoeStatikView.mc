using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Sensor;
using Toybox.ActivityRecording;
using Toybox.FitContributor;
using Toybox.Graphics;
using Toybox.Attention;

const FIT_FIELD_PHASE_ID = 0;

const NAME = "name";
const PROPERTY = "property";

const ALARM_BEEP_PROP_NAME = "alarmBeep";
const ALARM_VIBRATE_PROP_NAME = "alarmVibrate";

// Wir geben den phasen hier Namen.
// Sollten wir einmal zusätzliche Phasen einführen, muss nicht der ganze Code nach hardcodierten Zahlen durchsucht werden.
// Zum Beispiel relevant im Alarm-Code.
const RELAX1 = 0;
const HYPERVEN = 1;
const RELAX2 = 2;
const STATIK = 3;

var sequenz = [
    { // [0]   RELAX1
      NAME => Rez.Strings.phase1,
      PROPERTY => "phase1Duration"
    },
    { // [1]   HYPERVEN
      NAME => Rez.Strings.phase2,
      PROPERTY => "phase2Duration"
    },
    { // [2]   RELAX2
      NAME => Rez.Strings.phase3,
      PROPERTY => "phase3Duration"
    },
    { // [3]   STATIK
      NAME => Rez.Strings.phase4,
      // LAST PHASE MUST NOT HAVE A PROPERTY
      // Dadurch wissen wir, welche phase die letzte ist.
    }
];

var current = 0;
var zeit; // zeit is in seconds * 10
var timerIsPaused = true;

var session = null;                                             // set up session variable


class ApnoeStatikView extends WatchUi.View {

    enum {
        UP = 1,
        DOWN = -1
    }
    hidden var timerDirection;

    hidden var modus;
    hidden var puls;

    hidden var fitField;

    hidden var timer = new Timer.Timer();

    function getDuration(seq) {
        var propName = seq[PROPERTY];
        if (propName == null) {
          return 0;
        }

        // Timer is called 10 times / second.
        // And every time we change the zeit variable.
        // The saved duration is in seconds.
        return Application.getApp().getProperty(propName) * 10;
    }

    function initialize() {
        restart();
        View.initialize();
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
    }

    function restart() {
        current = 0;
        timerIsPaused = true;
        session = null;

        timerDirection = DOWN;

        modus = sequenz[0][NAME];
        zeit = null; // zeit is in seconds * 10

        fitField = null;

        timer.start(method(:onTimer), 100, true);
    }

    function pop() {
        WatchUi.popView();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onSensor(sensorInfo) {
        puls = sensorInfo.heartRate;
        WatchUi.requestUpdate();
    }


// ----------- RECORD AND SAVE BEGINNING ------------

    // use the select Start/Stop or touch for recording
    function startActivityRecording() {
       if (Toybox has :ActivityRecording) {                          // check device for activity recording
           var activityname = WatchUi.loadResource(Rez.Strings.AppName);
           var datafield = WatchUi.loadResource(Rez.Strings.phase);
           var activityphase = activityname + " " + datafield;

           if ((session == null) || (session.isRecording() == false)) {
               session = ActivityRecording.createSession(            // set up recording session
                    {
                     :name=> activityname,                           // set session name
                     :sport=> ActivityRecording.SPORT_GENERIC,       // set sport type
                     :subSport=> ActivityRecording.SUB_SPORT_GENERIC // set sub sport type
                    }
               );
               fitField = session.createField(activityphase,
                                              FIT_FIELD_PHASE_ID,
                                              FitContributor.DATA_TYPE_UINT8,
                                              {:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=> datafield });
               fitField.setData(0);
               session.start();                                      // call start session
           }
       }
    }

    function stopActivityRecording() {
        if ((session != null) && session.isRecording()) {
             session.stop();           // stop the session
        }
    }

    function savePhaseInFitField() {
        if (fitField != null) {
            fitField.setData(current + 1);
        }
    }
// ----------- RECORD AND SAVE END --------------------
// ----------- ALARM PROGRAMMING BEGINNING ------------

    function displayOn() {
        if (Attention has :backlight) {
            Attention.backlight(true);
        }
    }

    function beepVibrate(dutyCycle, duration) {
      var beepEnabled = Application.getApp().getProperty(ALARM_BEEP_PROP_NAME);
      var vibrateEnabled = Application.getApp().getProperty(ALARM_VIBRATE_PROP_NAME);

      if (beepEnabled) {
        beep();
      }
      if (vibrateEnabled) {
        vibrate(dutyCycle, duration);
      }
    }

    function beep() {
        if (Attention has :playTone) {
            Attention.playTone(Attention.TONE_LOUD_BEEP);
        }
    }

    function vibrate(dutyCycle, duration) {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(dutyCycle, duration)]);
        }
    }


    function doAlarms() {
        var timeInSeconds = zeit / 10;

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
    //   if (current == 0 || current == 2) {
            // For phase 1 (relax-1) and phase 3 (relax-2) only.
            // Note that current starts with 0

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


        // zeit is in zehntel-Sekunden !
        if (current == RELAX1 || current == RELAX2 ) {
            if (zeit > 300 && zeit % 300 == 0) {
                beepVibrate(50, 250);
            } else if (zeit == 300 || zeit == 300-5 || zeit == 300-10) {
                beepVibrate(50, 250);
            } else if (zeit == 200 || zeit == 200-5) {
                beepVibrate(50, 250);
            } else if (zeit == 100) {
                beepVibrate(50, 250);
            } else if (zeit == 0) { // zeit == 0 wird gefragt bevor zeit <= 50 (nächster if block)
                beepVibrate(100, 750);
            } else if (zeit <= 50 && zeit % 10 == 0) {  // durch else if   wird dieser block nicht ausgeführt, wenn zeit == 0
                beepVibrate(50, 250);                   // alternativ könnte man && zeit > 0 zum if hinzufügen.
            }
         }


         if (current == HYPERVEN) {
            if (zeit == 0) { // zeit == 0 wird gefragt bevor zeit <= 50 (nächster if block)
                beepVibrate(100, 750);
            } else if (zeit <= 50 && zeit % 10 == 0) {  // durch else if   wird dieser block nicht ausgeführt, wenn zeit == 0
                beepVibrate(50, 250);                   // alternativ könnte man && zeit > 0 zum if hinzufügen.
            }
         }


         if (current == STATIK) {
            if (zeit <= 50 && zeit % 10 == 0 && zeit > 0) {  // 0 wird eh noch vom RELAX2 0er alarmiert.
                beepVibrate(50, 250);
            }
         }
    }
// ----------- ALARM PROGRAMMING END ------------



    function onTimer() {
        var lastPhase = sequenz.size() - 1;

        if (timerIsPaused) {
            if (current == lastPhase) {
                // Because we stop the timer here, this is only called once.
                // And only possible if we are already in the last phase (current == sequenz.size() - 1)
                stopActivityRecording();
                timer.stop();
            }
            return;
        }
        if (session == null) {
            startActivityRecording();
            savePhaseInFitField();
        }

        // Only set the zeit when we really start the count down.
        // This is necessary as the menu could possible change the time before we start the count down.
        if (zeit == null) {
            zeit = getDuration(sequenz[0]);
        }

        zeit += timerDirection;

        doAlarms();

        if (zeit == 0 || zeit < 0) {
            current += 1;
            savePhaseInFitField();

            modus = sequenz[current][NAME];
            zeit = getDuration(sequenz[current]);

            if (current == sequenz.size() - 1) {
                //current += 1; // invalid current, but easy to check, if we have finished
                savePhaseInFitField();
                timerDirection = UP;
            }
        }
        WatchUi.requestUpdate();
    }

    function convertTimeToText(timeIn100ms) {
        // Add 9/10 of a second when calculating the timeInS.
        // If for instance a phase has a duration of one second, we want to display 1 for the whole second, before going to 0.
        // This is not true when counting upwards.
        var adjustment = timerDirection == DOWN ? 9 : 0;

        var timeInS = (timeIn100ms + adjustment) / 10;

        var seconds = timeInS % 60;  // % ist Rest von Division

        // %02d bedeutet zwei Stellen mit führender 0
        // https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Lang/Number.html#format-instance_method
        //  x / y ist ganzahlige Division
        var result = "" + timeInS / 60 + ":" + seconds.format("%02d");
        return result;
    }

    // Update the view
    function onUpdate(dc) {
        var currentZeit = zeit;
        if (currentZeit == null) {
          currentZeit = getDuration(sequenz[0]);
        }
        var zeitText = convertTimeToText(currentZeit);

        var textFeld;
        textFeld = View.findDrawableById("modusId");
        textFeld.setText(modus);

        textFeld = View.findDrawableById("zeitId");
        textFeld.setText(zeitText);

        textFeld = View.findDrawableById("pulsId");
        var hrPrefix = WatchUi.loadResource(Rez.Strings.heartRatePrefix);
        if (puls != null && puls > 0) {
            textFeld.setText(hrPrefix + " " + puls);
        } else {
            textFeld.setText(hrPrefix + " --");
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        //dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_RED);
        //dc.fillRectangle(100, 100, 100, 100);

        //dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        //dc.fillCircle(50, 100, 75);

        //dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_GREEN);
        //dc.drawText(100, 150, Graphics.FONT_NUMBER_THAI_HOT, "123", Graphics.TEXT_JUSTIFY_LEFT);
    }
}


