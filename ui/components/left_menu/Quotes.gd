extends Label

@export var author_label: Label

var quotes              : Array[String]
var current_quote_index : int        = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	load_quotes()
	set_process(false)
	change_quote(0)
	pass # Replace with function body.

func format_quote(csv_line: Array) -> String:
	prints("CSV Line: ", csv_line)
	return csv_line[0] + "\n\t- " + csv_line[1]

	
func load_quotes():
	var file_path = "res://assets/data/quotes.json"
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var error_parse = json.parse(content)
			if error_parse == OK:
				var data = json.get_data()
				for item in data:
					var quote_text = item["quote"]
					var author = item["author"]
					quotes.append("\"" + quote_text + "\"\n\t- " + author)
			else:
				push_error("Failed to parse JSON with error: " + str(error_parse))
		else:
			push_error("Failed to open JSON file at path: " + file_path)
	else:
		push_error("JSON file does not exist at path: " + file_path)




func change_quote( index : int ):
	text = quotes[index]
	if author_label:
		text = quotes[index].split("\n\t- ")[0]
		author_label.text = quotes[index].split("- ")[-1]

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
