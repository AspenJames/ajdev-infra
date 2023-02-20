output "private_key" {
  value     = tls_private_key.this.private_key_openssh
  sensitive = true
}

output "public_ip" {
  value = module.ajdev-node.public_ip
}
