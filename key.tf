resource "tls_private_key" "ansible_git" {
  count = "${var.CREATE_ANSIBLE_GIT_KEY == "true" ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "ansible_git" {
  count = "${var.CREATE_ANSIBLE_GIT_KEY == "true" ? 1 : 0}"
  content = "${tls_private_key.ansible_git.private_key_pem}"
  filename = "${format("%s/.ssh/%s", pathexpand("~"), var.ANSIBLE_GIT_KEY)}"
  provisioner "local-exec" {
    command = "chmod 600 ${format("%s/.ssh/%s", pathexpand("~"), var.ANSIBLE_GIT_KEY)}"
  }
}

resource "local_file" "ansible_git_public" {
  count = "${var.CREATE_ANSIBLE_GIT_KEY == "true" ? 1 : 0}"
  content = "${tls_private_key.ansible_git.public_key_openssh}"
  filename = "${format("%s/.ssh/%s.pub", pathexpand("~"), var.ANSIBLE_GIT_KEY)}"
}

# Seems to me like naming a data source "tls_public_key" when it really extracts private key data is a terraform bug
data "tls_public_key" "ansible_git" {
  count = "${var.CREATE_ANSIBLE_GIT_KEY == "true" ? 1 : 0}"
  private_key_pem = "${tls_private_key.ansible_git.private_key_pem}"
}
