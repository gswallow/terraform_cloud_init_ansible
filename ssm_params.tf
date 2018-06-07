resource "aws_ssm_parameter" "ansible_git" {
  name  = "/ansible/common/git/private_key"
  count = "${var.CREATE_SSM_PARAMETERS == true ? 1 : 0 }"
  description  = "Ansible git user private key"
  type  = "SecureString"
  overwrite = true
  value = "${data.tls_public_key.ansible_git.private_key_pem}"
  tags {
    Environment = "${var.ENV}"
  }
}
