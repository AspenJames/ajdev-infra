output "private_key" {
  description = "OpenSSH private key to connect to instance"
  value       = tls_private_key.this.private_key_openssh
  sensitive   = true
}

output "public_ip" {
  description = "Instance ip"
  value       = module.ajdev-node.public_ip
}
