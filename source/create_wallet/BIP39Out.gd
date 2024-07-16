extends RichTextLabel

func _ready():
	clear()
	append_text("bip39 hex: 1998a88b5f37913e6dd468330fdeb8b3\n")
	append_text("bip39 dec: 34023347504116446333364760405602121907\n")
	append_text("bip39 bin: 0001 1001 1000 1010 1000 1000 0101 1111 0011 1001 0001 0011 1110 0110 1101 1101 0100 0110 1000 0011 0011 0000 1111 1101 1110 1011 1000 1011 0011 ")
	push_color(Color(1, .5, 0))  # Set color to blue
	append_text("1110\n")
	pop()  # Revert to previous color
	append_text("bip39 csum: 'e' ")
	push_color(Color(1, .5, 0))  # Set color to blue
	append_text("1110\n")
	pop()
	append_text("HD key data: e6242ece817a1aed46ae3cda9a78bdfa6652a9b7cb5690849b6b442ad0d478c4\n\n")
	append_text("BIP39 Mnemonic Words: ")
