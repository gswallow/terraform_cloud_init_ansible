resource "tls_private_key" "ansible_git" {
  count = "${var.CREATE_ANSIBLE_GIT_KEY == "true" ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits = 4096
  provisioner "local-exec" { 
    command = "echo ${tls_private_key.ansible_git.private_key_pem} > ${var.ANSIBLE_GIT_KEY} && chmod 600 ${var.ANSIBLE_GIT_KEY}"
  }
  provisioner "local-exec" { 
    command = "echo ${tls_private_key.ansible_git.public_key_openssh} > ${var.ANSIBLE_GIT_KEY}.pub"
  }
}

# Seems to me like naming a data source "tls_public_key" when it really extracts private key data is a terraform bug
data "tls_public_key" "ansible_git" {
  count = "${var.CREATE_ANSIBLE_GIT_KEY == "true" ? 1 : 0}"
  private_key_pem = "${tls_private_key.ansible_git.private_key_pem}"
}
