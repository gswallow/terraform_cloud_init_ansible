# The IAM instance profile
resource "aws_iam_instance_profile" "current" {
  name_prefix = "ansible_node"
  role = "${aws_iam_role.current.name}"
}

# Which gets bound to the IAM role, with a trust
# relationship to the ec2.amazonaws.com service
resource "aws_iam_role" "current" {
  name_prefix = "ansible_node"
  path = "/"

  # The trusted entity in the IAM role
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": "SSMParameterAccess"
        }
    ]
}
EOF
}

# The policy statements get attached to the IAM role's
# policy, allowing instances that use sts:AssumeRole to
# use permission herein
resource "aws_iam_role_policy_attachment" "ansible_ssm_parameter" {
  role       = "${aws_iam_role.current.name}"
  policy_arn = "${aws_iam_policy.read_ansible_ssm_parameters.arn}"
}

output "iam_instance_profile_id" {
  value = "${aws_iam_instance_profile.current.id}"
}

output "iam_role_arn" {
  value = "${aws_iam_role.current.arn}"
}

output "iam_role_name" {
  value = "${aws_iam_role.current.name}"
}
