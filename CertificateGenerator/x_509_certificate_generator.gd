extends Node

var X509_cert_filename = "X509_Certificate.crt"
var X509_key_filename = "X509_key.key"

@onready var X509_cert_path = "user://Certificate/" + X509_cert_filename
@onready var X509_key_path = "user://Certificate/" + X509_key_filename

var CN = "GodotMultiplayerGame"
var O = "Vickylance"
var C = "IN"
var not_before = "20240101000000"
var not_after = "20241230000000"


func _ready() -> void:
	var dir := DirAccess.open("user://")
	if dir.dir_exists("Certificate"):
		pass
	else:
		dir.make_dir("Certificate")
	create_x509_certificate()
	print("Certificate created")
	pass


func create_x509_certificate() -> void:
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var x509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	x509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
	pass
