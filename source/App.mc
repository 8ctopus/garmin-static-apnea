using Toybox.Application;

const FIT_FIELD_PHASE_ID = 0;

const NAME = "name";
const PROPERTY = "property";

const ALARM_BEEP_PROP_NAME = "alarmBeep";
const ALARM_VIBRATE_PROP_NAME = "alarmVibrate";

// set up session variable
var gSession = null;

// we give the phases names in the event if we want to add more, we don't have to change the code
const RELAX1 = 0;
const HYPERVEN = 1;
const RELAX2 = 2;
const STATIK = 3;

var gPhases = [
    {
        // relaxation
        NAME => Rez.Strings.phase1,
        PROPERTY => "phase1Duration"
    }, {
        // hyperventilation
        NAME => Rez.Strings.phase2,
        PROPERTY => "phase2Duration"
    }, {
        // relaxation
        NAME => Rez.Strings.phase3,
        PROPERTY => "phase3Duration"
    }, {
        // static apnea
        // LAST PHASE MUST NOT HAVE A PROPERTY so we know which one is the last one
        NAME => Rez.Strings.phase4,
    }
];

var gCurrentPhase = 0;

// in seconds * 10
var gTime;
var gTimerIsPaused = true;

class App extends Application.AppBase {
    public function initialize() {
        AppBase.initialize();
    }

    public function getInitialView() {
        var view = new View();
        return [view, new Delegate(view)];
    }
}
