# cloud_init_ansible

This module creates user-data for Amazon EC2 instances to run `ansible-pull` through cloud-init.
Along with the user-data, it can store an SSH private key in AWS SSM Parameter Store and 
create an IAM profile allowing read access to the stored parameter.  The EC2 instance's IAM 
policies can be extended by attaching additional policy documents to the linked IAM role.

The TF\_VAR\_STORE\_ANSIBLE\_GIT\_KEY environment variable controls whether this module will
store the SSH key in SSM.

If the TF\_VAR\_ENABLE\_AWS\_MANAGEMENT\_AGENTS environment variable is set to "true", then
the base IAM policies attached to the instance's IAM role allow for AWS Simple Systems
Manager and Cloudwatch agents to work as they should.  Additionally, this template will update
SSM parameters containing Cloudwatch agent configurations for Linux and Windows.  Actually
installing and configuring Cloudwatch agents is to be done with Ansible.

If the TF\_VAR\_CREATE\_AWS\_MANAGEMENT\_POLICY environment variable is set to "true", then
this module will create a restricted EC2 policy like AWS's "AmazonEC2RoleforSSM" managed
policy.  AWS's managed policy allows unrestricted read access to S3!

The module injects four environment variables into the user-data:

* ENV is the environment that the EC2 instance resides in (e.g. development, production)
* ORG is the organization that the EC2 instance belongs to (e.g. your company name)
* HOSTGROUP places the EC2 instance into an Ansible host group (like a Chef role)
* ANSIBLE\_PLAYBOOKS\_REPO is the URL of your Ansible playbooks Git repository

All EC2 instances will end up in two host groups -- `$ENV` and `$HOSTGROUP` -- if you use the
hostgroup.py inventory script, from the examples folder, in your ansible repo's inventory scripts.

# Setup

![Object relationhips](docs/cloud-init-modules.png)

By including the module and passing in some variables, you will end up with an IAM instance
profile that allows your EC2 instance to retrieve a private SSH key.  This key is for use
with ansible-pull (or git clone). 

## Including the module

Note that in this directory, there is a script called "create-skel.sh."  
The script will create a \_bootstrap.tf file in the root of your config:

```
variable "HOSTGROUP" { default = "default" }
variable "ANSIBLE_PLAYBOOKS_REPO" { }

module "cloud_init_ansible" {
  source = "../../modules/cloud_init_ansible"
  ENV = "${var.ENV}"
  ORG = "${var.ORG}"
  HOSTGROUP = "${var.HOSTGROUP}"
  ANSIBLE_PLAYBOOKS_REPO = "${var.ANSIBLE_PLAYBOOKS_REPO}"

  ANSIBLE_GIT_KEY = "~/.ssh/ansible_rsa"
  STORE_ANSIBLE_GIT_KEY = "false"
  ENABLE_AWS_MANAGEMENT_AGENTS = "true"
  CREATE_AWS_MANAGEMENT_POLICY = "false"
}
```

Optionally, you can edit the \_bootstrap.tf file and change some of the values:

| Variable (TF\_VAR\_\*)          |                                                                         | Default             |
|---------------------------------|-------------------------------------------------------------------------|---------------------|
| ENV                             | The name of your environment (e.g. prod, dev, staging)                  | None                |
| ORG                             | The name of your organization (e.g. 'ivytech')                          | None                |
| HOSTGROUP                       | The name of the hostgroup that this host belongs to (e.g. 'webservers') | None                |
| ANSIBLE\_GIT\_KEY               | SSH key file name                                                       | ~/.ssh/ansible\_rsa |
| ANSIBLE\_PLAYBOOKS\_REPO        | The git repository for your Ansible Playbooks                           | None                |
| STORE\_ANSIBLE\_GIT\_KEY        | Stores the Ansible git private key in SSM Parameter Store               | false               |
| ENABLE\_AWS\_MANAGEMENT\_AGENTS | Add RestrictedEC2RoleforSSM and CloudWatchAgentServerPolicy to IAM role | true                |
| CREATE\_AWS\_MANAGEMENT\_POLICY | Create an EC2 policy allowing SSM and Cloudwatch agents to work         | false               |

## Example: creating the SSM parameter

The \_bootstrap.tf and \_variables.tf files in the examples folder actually create a private SSH key and store them
in an AWS SSM parameter.

# Using Outputs

There are two user-data outputs, `debian` and `redhat`:

Just insert the results of the module in your user_data, when creating an instance or a launch config:

```
resource "aws_instance" "mine" {
  ami           = "${module.redhat_ami.id}"
  user_data     = "${module.cloud_init_ansible.redhat_user_data}"
  tags {
    Environment = "${var.ENV}"
  }
}
```

# Using / Extending IAM permissions

There are outputs for IAM instance profiles and roles: `iam_instance_profile_id` and `iam_role_name`.
For example, attach a profile to an EC2 instance:

```
resource "aws_instance" "mine" {
  ami                  = "${module.redhat_ami.id}"
  iam_instance_profile = "${module.cloud_init_ansible.iam_instance_profile_id}"
  ...
  tags {
    Environment        = "${var.ENV}"
  }
}
```

Or, extend an EC2 instance's permissions by creating a new policy and attaching it to the IAM role:

```
resource "aws_iam_policy" "s3_get_items" {
  ...
}

resource "aws_iam_policy_attachment" "s3_get_items_policy" {
  roles      = ["${module.cloud_init_ansible.iam_role_name}"]
  policy_arn = "${aws_iam_policy.s3_get_items.arn}"
}
```

# TODO

I use Red Hat Enterprise Linux at my current job.  Because you can't install any packages, or 
pretty much do anything with RHEL before registering your license, we have a Packer template 
that takes care of things like installing Python, pip, Ansible, and AWS packages.  Those items
might need to be addressed in the user-data script with yum localinstall.

The debian (ok, ubuntu) template needs rehashed.
