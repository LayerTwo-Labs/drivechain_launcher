extends PanelContainer

@onready var quotes_label: Label = $MarginContainer/HBox/Quotes
@onready var author_label: Label = $MarginContainer/HBox/Author
@onready var next_button: Button = $MarginContainer/HBox/NextButton
@onready var prev_button: Button = $MarginContainer/HBox/PrevButton

var quotes: Array = []  # Changed to untyped Array
var current_quote_index: int = 0

func _ready() -> void:
	load_quotes()
	change_quote(0)
	next_button.pressed.connect(self._on_next_button_pressed)
	prev_button.pressed.connect(self._on_prev_button_pressed)

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
				if data is Array:
					quotes = data  # Directly assign the parsed data
				else:
					push_error("JSON data is not an array")
			else:
				push_error("Failed to parse JSON with error: " + str(error_parse))
	else:
		push_error("JSON file does not exist at path: " + file_path)

func change_quote(index: int):
	if quotes.is_empty():
		return
	var quote_data = quotes[index]
	if quote_data is Dictionary and quote_data.has("quote") and quote_data.has("author"):
		quotes_label.text = "\"" + quote_data["quote"] + "\""
		author_label.text = "- " + quote_data["author"]
	else:
		push_error("Invalid quote data format")

func fade_quote(index: int):
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(quotes_label, "modulate", Color(1,1,1,0), 0.25)
	fade_tween.parallel().tween_property(author_label, "modulate", Color(1,1,1,0), 0.25)
	await fade_tween.finished
	change_quote(index)
	fade_tween = create_tween()
	fade_tween.tween_property(quotes_label, "modulate", Color(1,1,1,1), 0.25)
	fade_tween.parallel().tween_property(author_label, "modulate", Color(1,1,1,1), 0.25)

func _on_next_button_pressed():
	current_quote_index = (current_quote_index + 1) % quotes.size()
	fade_quote(current_quote_index)

func _on_prev_button_pressed():
	current_quote_index = (current_quote_index - 1 + quotes.size()) % quotes.size()
	fade_quote(current_quote_index)
