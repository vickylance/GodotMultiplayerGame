extends SceneTree

var X509_cert_filename = "X509_Certificate.crt"
var X509_key_filename = "X509_key.key"

var CN = "GodotMultiplayerGame"
var O = "Vickylance"
var C = "IN"
var not_before = "20260101000000"
var not_after = "20261230000000"


func _init() -> void:
	var cert_dir = "res://certs/"
	if not DirAccess.dir_exists_absolute(cert_dir):
		DirAccess.make_dir_recursive_absolute(cert_dir)
		
	create_x509_certificate()
	var X509_cert_path = cert_dir + X509_cert_filename
	print("Certificate created at: ", ProjectSettings.globalize_path(X509_cert_path))
	quit()


func create_x509_certificate() -> void:
	var X509_cert_path = "res://certs/" + X509_cert_filename
	var X509_key_path = "res://certs/" + X509_key_filename
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var x509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	x509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
