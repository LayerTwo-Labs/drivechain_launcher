extends GridContainer

var address_data = [
	{"Path": "m/0'/0'/0'", "PrivKey": "L5S8FnQHDM...", "Address": "1c3EpB13nVYafgYGLCVBA8gsKsAjTzRzV"},
	{"Path": "m/0'/0'/1'", "PrivKey": "KzDne4jYyB...", "Address": "13sVRT6SdTSGfWWgLWiWg4JjLHoI54rzp89gX"},
	{"Path": "m/0'/0'/2'", "PrivKey": "Ks0Q3vRo3v...", "Address": "1AnLzkCsBb5uzik8hwsj8Ymfw6dgybXhHv"},
	{"Path": "m/0'/0'/3'", "PrivKey": "LzciFh7taa...", "Address": "1Fqam1rJdjsGybKbhYol2d2aiqQqhbDLDRf"},
	{"Path": "m/0'/0'/4'", "PrivKey": "KywrRC6B71...", "Address": "1ASgCjWVCnV9ewHseLsoIdzkMpjQHTcR9cRgv"},
	{"Path": "m/0'/0'/5'", "PrivKey": "L3ighBr5vN...", "Address": "1MzXoxv35T7f9AoYHmcquhXrPoFmLT7EN9"},
	{"Path": "m/0'/0'/6'", "PrivKey": "K2X5fUw8uN...", "Address": "1B06B7Jw2VzXrthrMQzuUXoQUFWqQCHJ"},
	{"Path": "m/0'/0'/7'", "PrivKey": "LW4J3z4djR...", "Address": "1A8obBffmYsuXuJxabUryo3exNYh5kJ4SLm"},
	{"Path": "m/0'/0'/8'", "PrivKey": "KSwoxK4wtF...", "Address": "15XLVfGk67MmV5xaYSbfHbfeA9UVy9B44"},
	{"Path": "m/0'/0'/9'", "PrivKey": "K2HgQdGwvA...", "Address": "1mwdEAD4K8VDxBsMAKbfU1PursAt4tGGB81"},
	{"Path": "m/0'/0'/10'", "PrivKey": "Kc9fA73uHE...", "Address": "1Mj0w0ZEKRRf3mLhCnr9nRt5tbNCYKfMKNk"},
	{"Path": "m/0'/0'/11'", "PrivKey": "L4oV4K1QGK...", "Address": "1hWrbZDiV8fkNahn5w8a5n5tgSoBz7Hjei"},
	{"Path": "m/0'/0'/12'", "PrivKey": "Kp4vUfySZS...", "Address": "13rsDVltJgftR8V3oh42Wfcdug4p5Aj"},
	{"Path": "m/0'/0'/13'", "PrivKey": "L1XqOwsSwg...", "Address": "17hKX5rFM7zSVG4AVjPGH9J96NfMmgdGM"},
	{"Path": "m/0'/0'/14'", "PrivKey": "KzGn4utrow...", "Address": "1NgLSE3YM4wCm4NCanSzDfyRkiaKMcZazZh"},
	{"Path": "m/0'/0'/15'", "PrivKey": "L3pAEFRfQo...", "Address": "1Nic5SmKufth421r9CjxG8C8nuPGFTSmXJ"},
	{"Path": "m/0'/0'/16'", "PrivKey": "KyAq5Ktjqg...", "Address": "1SFfwRYmWy7tdRiLxrDrs8Q2aUAWsmMpM"},
	{"Path": "m/0'/0'/17'", "PrivKey": "L2mQXwq4Bd...", "Address": "18LwMd83Wf3eV8spNj1pYYF7XS5z2rS3"},
	{"Path": "m/0'/0'/18'", "PrivKey": "KwmS6R8wzG...", "Address": "17jCsKExwW3buv2Apx5zN2G6H8M5qKqxL7"},
	{"Path": "m/0'/0'/19'", "PrivKey": "LXVq8Nswg...", "Address": "1hK5PXFrM7zSVG4AVjPGH9J96NfMmgdGM"},
	{"Path": "m/0'/0'/20'", "PrivKey": "L4ZgAn5RTE...", "Address": "1BAz7CyzYyPxpBqJ4Ax4YwHf8B9gUXY"},
	{"Path": "m/0'/0'/21'", "PrivKey": "L2Gy4LqCNE...", "Address": "1BJkTSy3NQpfHTytHn6j1PKfNEFnDtmvTA"},
	{"Path": "m/0'/0'/22'", "PrivKey": "K2GyJt4wBz...", "Address": "14M5NwZL4WANc5zAMV4CnmPzT5W4MdC4"},
	{"Path": "m/0'/0'/23'", "PrivKey": "L3ijXRyED6...", "Address": "1pBkkfdFkUWAAfwboQ13PSmTn9tRyaHyWN"},
	{"Path": "m/0'/0'/24'", "PrivKey": "LXVVx2Mgp...", "Address": "1JHf6NLJ3iwbXYTbKehMja6Z9bKnBAmntXSo"},
	{"Path": "m/0'/0'/25'", "PrivKey": "L2Qk0LApm...", "Address": "15JvNGSNaZyUq4F8Fh1Nuzo4gfCHHXSDo"},
	{"Path": "m/0'/0'/26'", "PrivKey": "LZK1ggn5Rp...", "Address": "1Ak8YsbTxeARnb8Whb4aHckbuwwF1XFL"},
	{"Path": "m/0'/0'/27'", "PrivKey": "L2MsQdT8Ek...", "Address": "1Hj5neIJoobDxmXyz1XpXaAysF8exue3y9"},
	{"Path": "m/0'/0'/28'", "PrivKey": "KxMgeAQFhx...", "Address": "1Kv5tEkdA7DHqM4rW6ypE8AnPLDMSdCpDc"},
	{"Path": "m/0'/0'/29'", "PrivKey": "L2XysnSMoW...", "Address": "18TFHNsQ3OtzYuzyjGNUTn4J6WMaSdQ3dKE"}
]

func _ready():
	# Add header labels
	add_label("Path", true)
	add_label("PrivKey", true)
	add_label("Address", true)
	
	# Add data labels
	for data in address_data:
		add_label(data["Path"], false)
		add_label(data["PrivKey"], false)
		add_label(data["Address"], false)

func add_label(text: String, is_header: bool):
	var label = Label.new()
	label.text = text
	if is_header:
		label.add_theme_color_override("font_color", Color(1, 1, 1))  # White color for header
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))  # Light gray color for data
	add_child(label)
