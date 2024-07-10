extends GridContainer

# Example data
var mnemonic_data = [
	{"bitstream": "000 1100 1100", "index": "204", "word": "book"},
	{"bitstream": "110 0010 1010", "index": "1578", "word": "shed"},
	{"bitstream": "001 0001 0110", "index": "278", "word": "carpet"},
	{"bitstream": "101 1111 0011", "index": "1523", "word": "salmon"},
	{"bitstream": "011 1100 1000", "index": "968", "word": "jungle"},
	{"bitstream": "100 1111 1001", "index": "1273", "word": "palace"},
	{"bitstream": "101 1011 1010", "index": "1466", "word": "resemble"},
	{"bitstream": "100 0110 1000", "index": "1128", "word": "minimum"},
	{"bitstream": "001 1001 1000", "index": "408", "word": "credit"},
	{"bitstream": "101 1111 0111", "index": "1015", "word": "leave"},
	{"bitstream": "101 0111 0001", "index": "1393", "word": "purchase"},
	{"bitstream": "011 0011 1110", "index": "830", "word": "guitar"},
]

func _ready():
	# Load necessary headers using relative paths
	
	add_label("Bitstream", true)
	add_empty_label()
	add_label("Index", true)
	add_empty_label()
	add_label("Word", true)
	
	# Add data labels with empty columns
	for data in mnemonic_data:
		add_label(data["bitstream"], false)
		add_empty_label()
		add_label(data["index"], false)
		add_empty_label()
		add_label(data["word"], false)

func add_label(text: String, is_header: bool):
	var label = Label.new()
	label.text = text
	if is_header:
		label.add_theme_color_override("font_color", Color(1, 1, 1))  # White color for header
	else:
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))  # Light gray color for data
	add_child(label)

func add_empty_label():
	var empty_label = Label.new()
	empty_label.text = ""  # Add an empty string to create a blank column
	add_child(empty_label)
