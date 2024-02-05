extends Button
class_name ActionButton


enum {
	DOWNLOAD,
	RUN,
	STOP
}

const state_name : Array[String] = [
	"Download",
	"Run",
	"Stop"
]

@export_enum("Download", "Run", "Stop") var state          : int    = DOWNLOAD
@export                                 var show_icon      : bool   = true
@export_file("*.svg", "*.png")          var Download_Icon  : String
@export_color_no_alpha                  var Download_Color : Color  = Color.RED
@export_file("*.svg", "*.png")          var Run_Icon       : String
@export_color_no_alpha                  var Run_Color      : Color  = Color.BLUE
@export_file("*.svg", "*.png")          var Stop_Icon      : String
@export_color_no_alpha                  var Stop_Color     : Color  = Color.GREEN

@onready                                var Context_Color  : Array[Color] = [Download_Color, Run_Color, Stop_Color]


func _ready():
	set_state(state)


func set_state(new_state:int):
	if new_state == state: return
	state = new_state
	set_text(state_name[state])
	theme
