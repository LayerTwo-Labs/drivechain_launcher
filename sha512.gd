class_name SHA512

const K = [
	[0x428a2f98, 0xd728ae22], [0x71374491, 0x23ef65cd], [0xb5c0fbcf, 0xec4d3b2f], [0xe9b5dba5, 0x8189dbbc],
	[0x3956c25b, 0xf348b538], [0x59f111f1, 0xb605d019], [0x923f82a4, 0xaf194f9b], [0xab1c5ed5, 0xda6d8118],
	[0xd807aa98, 0xa3030242], [0x12835b01, 0x45706fbe], [0x243185be, 0x4ee4b28c], [0x550c7dc3, 0xd5ffb4e2],
	[0x72be5d74, 0xf27b896f], [0x80deb1fe, 0x3b1696b1], [0x9bdc06a7, 0x25c71235], [0xc19bf174, 0xcf692694],
	[0xe49b69c1, 0xefbe4786], [0x0fc19dc6, 0x8b8cd5b5], [0x240ca1cc, 0x77ac9c65], [0x2de92c6f, 0x592b0275],
	[0x4a7484aa, 0x6ea6e483], [0x5cb0a9dc, 0xbd41fbd4], [0x76f988da, 0x831153b5], [0x983e5152, 0xee66dfab],
	[0xa831c66d, 0x2db43210], [0xb00327c8, 0x98fb213f], [0xbf597fc7, 0xbeef0ee4], [0xc6e00bf3, 0x3da88fc2],
	[0xd5a79147, 0x930aa725], [0x06ca6351, 0xe003826f], [0x14292967, 0x0a0e6e70], [0x27b70a85, 0x46d22ffc],
	[0x2e1b2138, 0x5c26c926], [0x4d2c6dfc, 0x5ac42aed], [0x53380d13, 0x9d95b3df], [0x650a7354, 0x8baf63de],
	[0x766a0abb, 0x3c77b2a8], [0x81c2c92e, 0x47edaee6], [0x92722c85, 0x1482353b], [0xa2bfe8a1, 0x4cf10364],
	[0xa81a664b, 0xbc423001], [0xc24b8b70, 0xd0f89791], [0xc76c51a3, 0x0654be30], [0xd192e819, 0xd6ef5218],
	[0xd6990624, 0x5565a910], [0xf40e3585, 0x5771202a], [0x106aa070, 0x32bbd1b8], [0x19a4c116, 0xb8d2d0c8],
	[0x1e376c08, 0x5141ab53], [0x2748774c, 0xdf8eeb99], [0x34b0bcb5, 0xe19b48a8], [0x391c0cb3, 0xc5c95a63],
	[0x4ed8aa4a, 0xe3418acb], [0x5b9cca4f, 0x7763e373], [0x682e6ff3, 0xd6b2b8a3], [0x748f82ee, 0x5defb2fc],
	[0x78a5636f, 0x43172f60], [0x84c87814, 0xa1f0ab72], [0x8cc70208, 0x1a6439ec], [0x90befffa, 0x23631e28],
	[0xa4506ceb, 0xde82bde9], [0xbef9a3f7, 0xb2c67915], [0xc67178f2, 0xe372532b], [0xca273ece, 0xea26619c],
	[0xd186b8c7, 0x21c0c207], [0xeada7dd6, 0xcde0eb1e], [0xf57d4f7f, 0xee6ed178], [0x06f067aa, 0x72176fba],
	[0x0a637dc5, 0xa2c898a6], [0x113f9804, 0xbef90dae], [0x1b710b35, 0x131c471b], [0x28db77f5, 0x23047d84],
	[0x32caab7b, 0x40c72493], [0x3c9ebe0a, 0x15c9bebc], [0x431d67c4, 0x9c100d4c], [0x4cc5d4be, 0xcb3e42b6],
	[0x597f299c, 0xfc657e2a], [0x5fcb6fab, 0x3ad6faec], [0x6c44198c, 0x4a475817]
]

static func rotr(n: int, x: Array) -> Array:
	var a = x[0]
	var b = x[1]
	if n >= 32:
		n -= 32
		var t = a
		a = b
		b = t
	if n == 0:
		return [a, b]
	return [
		((a >> n) | (b << (32 - n))) & 0xFFFFFFFF,
		((b >> n) | (a << (32 - n))) & 0xFFFFFFFF
	]

static func add_modulo(a: Array, b: Array) -> Array:
	var lo = (a[1] + b[1]) & 0xFFFFFFFF
	var hi = (a[0] + b[0] + (1 if lo < a[1] else 0)) & 0xFFFFFFFF
	return [hi, lo]

static func ch(x: Array, y: Array, z: Array) -> Array:
	return [
		(x[0] & y[0]) ^ (~x[0] & z[0]),
		(x[1] & y[1]) ^ (~x[1] & z[1])
	]

static func maj(x: Array, y: Array, z: Array) -> Array:
	return [
		(x[0] & y[0]) ^ (x[0] & z[0]) ^ (y[0] & z[0]),
		(x[1] & y[1]) ^ (x[1] & z[1]) ^ (y[1] & z[1])
	]

static func sigma0(x: Array) -> Array:
	var a = rotr(28, x)
	var b = rotr(34, x)
	var c = rotr(39, x)
	return [a[0] ^ b[0] ^ c[0], a[1] ^ b[1] ^ c[1]]

static func sigma1(x: Array) -> Array:
	var a = rotr(14, x)
	var b = rotr(18, x)
	var c = rotr(41, x)
	return [a[0] ^ b[0] ^ c[0], a[1] ^ b[1] ^ c[1]]

static func gamma0(x: Array) -> Array:
	var a = rotr(1, x)
	var b = rotr(8, x)
	var c = [x[0] >> 7, (x[1] >> 7) | (x[0] << 25) & 0xFFFFFFFF]
	return [a[0] ^ b[0] ^ c[0], a[1] ^ b[1] ^ c[1]]

static func gamma1(x: Array) -> Array:
	var a = rotr(19, x)
	var b = rotr(61, x)
	var c = [x[0] >> 6, (x[1] >> 6) | (x[0] << 26) & 0xFFFFFFFF]
	return [a[0] ^ b[0] ^ c[0], a[1] ^ b[1] ^ c[1]]

static func sha512(message: PackedByteArray) -> PackedByteArray:
	var h = [
		[0x6a09e667, 0xf3bcc908], [0xbb67ae85, 0x84caa73b],
		[0x3c6ef372, 0xfe94f82b], [0xa54ff53a, 0x5f1d36f1],
		[0x510e527f, 0xade682d1], [0x9b05688c, 0x2b3e6c1f],
		[0x1f83d9ab, 0xfb41bd6b], [0x5be0cd19, 0x137e2179]
	]

	var message_len = message.size()
	var bit_len = message_len * 8
	message.append(0x80)
	while (message.size() % 128) != 112:
		message.append(0x00)

	for i in range(16):
		message.append((bit_len >> (120 - 8 * i)) & 0xFF)

	for chunk_start in range(0, message.size(), 128):
		var w = []
		for i in range(16):
			var start = chunk_start + i * 8
			w.append([
				(message[start] << 24) | (message[start + 1] << 16) | (message[start + 2] << 8) | message[start + 3],
				(message[start + 4] << 24) | (message[start + 5] << 16) | (message[start + 6] << 8) | message[start + 7]
			])

		for i in range(16, 80):
			var s0 = gamma0(w[i-15])
			var s1 = gamma1(w[i-2])
			var w_i = add_modulo(add_modulo(add_modulo(w[i-16], s0), w[i-7]), s1)
			w.append(w_i)

		var a = h[0]
		var b = h[1]
		var c = h[2]
		var d = h[3]
		var e = h[4]
		var f = h[5]
		var g = h[6]
		var hh = h[7]

		for i in range(80):
			var S1 = sigma1(e)
			var ch_efg = ch(e, f, g)
			var temp1 = add_modulo(add_modulo(add_modulo(add_modulo(hh, S1), ch_efg), K[i]), w[i])
			var S0 = sigma0(a)
			var maj_abc = maj(a, b, c)
			var temp2 = add_modulo(S0, maj_abc)

			hh = g
			g = f
			f = e
			e = add_modulo(d, temp1)
			d = c
			c = b
			b = a
			a = add_modulo(temp1, temp2)

		h[0] = add_modulo(h[0], a)
		h[1] = add_modulo(h[1], b)
		h[2] = add_modulo(h[2], c)
		h[3] = add_modulo(h[3], d)
		h[4] = add_modulo(h[4], e)
		h[5] = add_modulo(h[5], f)
		h[6] = add_modulo(h[6], g)
		h[7] = add_modulo(h[7], hh)

	var result = PackedByteArray()
	for i in range(8):
		for j in range(8):
			result.append((h[i][int(j/4)] >> (24 - 8 * (j % 4))) & 0xFF)
	return result

static func hmac_sha512(key: PackedByteArray, message: PackedByteArray) -> PackedByteArray:
	const BLOCK_SIZE = 128

	if key.size() > BLOCK_SIZE:
		key = sha512(key)

	while key.size() < BLOCK_SIZE:
		key.append(0)

	var o_key_pad = PackedByteArray()
	var i_key_pad = PackedByteArray()

	for i in range(BLOCK_SIZE):
		o_key_pad.append(key[i] ^ 0x5c)
		i_key_pad.append(key[i] ^ 0x36)

	var inner = i_key_pad + message
	var inner_hash = sha512(inner)

	var outer = o_key_pad + inner_hash
	return sha512(outer)
