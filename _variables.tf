variable "ORG" { }
variable "ENV" { }
variable "HOSTGROUP" { }
variable "REPO" { }

variable "CREATE_SSM_PARAMETERS" { default = "false" }
variable "CREATE_ANSIBLE_GIT_KEY" { default = "false" }
variable "ANSIBLE_GIT_KEY" { default = "~/.ssh/ansible_rsa" }
