extends Button
class_name ActionButton

enum {
	DOWNLOAD,
	RUN,
	STOP
}
var prev_state : int = -1

const state_name : Array[String] = [
	"Download",
	"Run",
	"Stop"
]

@export_enum("Download", "Run", "Stop") var state          : int              = DOWNLOAD
@export                                 var show_icon      : bool             = true
@export                                 var download_icon  : Texture2D
@export_color_no_alpha                  var download_color : Color            = Color.RED
@export                                 var download_theme : Theme
@export                                 var run_icon       : Texture2D
@export_color_no_alpha                  var run_color      : Color            = Color.BLUE
@export                                 var run_theme      : Theme
@export                                 var stop_icon      : Texture2D
@export_color_no_alpha                  var stop_color     : Color            = Color.GREEN
@export                                 var stop_theme     : Theme
@onready                                var state_icon     : Array[Texture2D] = [download_icon,  run_icon,  stop_icon]
@onready                                var state_Color    : Array[Color]     = [download_color, run_color, stop_color]
@onready                                var state_theme    : Array[Theme]     = [download_theme, run_theme, stop_theme]


func _ready():
	prints("State Icon: ", state_icon)
	set_state(state)

func set_state(new_state:int):
	if new_state == prev_state: return
	prev_state = state
	state = new_state
	set_text(state_name[state])
	set_button_icon(state_icon[state])
	set_theme(state_theme[state])
