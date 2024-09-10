output "bastion_private_key" {
  value     = tls_private_key.bastion_key.private_key_pem
  sensitive = true
}

output "bastion_key_pair" {
  value     = aws_key_pair.bastion_key
  sensitive = true
}
