extends Label

var quotes              : Array[String]
var current_quote_index : int        = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	load_quotes()
	set_process(false)
	change_quote(0)
	pass # Replace with function body.

func format_quote( csv_line : Array )->String:
	prints( "CSV Line: ", csv_line )
	return "\"" + csv_line[0] + "\"\n\t- " + csv_line[1]
	pass

func load_quotes():
	var file = FileAccess.open( "res://assets/csv/quotes.txt", FileAccess.READ )
	
	while !file.eof_reached():
		var csv_line : Array = Array( file.get_csv_line() ) 
		if csv_line.size() < 2: continue
		quotes.append( format_quote( csv_line ) )
	
	file.close()
	print(quotes)

func change_quote( index : int ):
	text = quotes[index]
	pass

func fade_quote( index : int ):
	var fade_tween : Tween = create_tween()
	fade_tween.tween_property(self, "modulate", Color(1.0,1.0,1.0,0.0),0.25)
	await(fade_tween.finished)
	change_quote(index)
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate", Color(1.0,1.0,1.0,1.0),0.25)

func _on_next_button_pressed():
	current_quote_index = (current_quote_index+1)%quotes.size()
	fade_quote(current_quote_index)
	pass # Replace with function body.


func _on_prev_button_pressed():
	current_quote_index = (current_quote_index-1)%quotes.size()
	fade_quote(current_quote_index)
	pass # Replace with function body.
