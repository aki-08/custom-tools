# Getting the custom ami created for the app servers

locals {
  app_tags = {
    "Name" = "${var.app_tier_name}"
	"App" = "${var.app_name}"
	"Env" = "${var.env_name}"
  }
}

data "aws_ami" "app-ami" {
  most_recent = true
  owners      = ["self"]
  
  filter {
    name   = "name"
    values = ["app-ami-*"]
  }
}

# Creating security group, launch configuration, autoscaling group and internal load balancer for app servers

resource "aws_security_group" "app" {
  name = "${var.app_sg}"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.public_subnets_cidr_blocks}", "${module.vpc.private_subnets_cidr_blocks}", "${module.vpc.database_subnets_cidr_blocks}"]
  }

  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.public_subnets_cidr_blocks}"]
  }

  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
  
  tags = "${local.app_tags}"
}

resource "aws_key_pair" "app_key" {
  key_name = "${var.app_key_name}"
  public_key = "${file(var.app_public_key)}"
}

resource "aws_launch_configuration" "app" {
  image_id        = "${data.aws_ami.app-ami.name}"
  instance_type   = "${var.app_instance_type}"
  security_groups = ["${aws_security_group.app.id}"]
  key_name = "${aws_key_pair.app_key.key_name}"
  name_prefix = "${var.app_tier_name}-vm-"
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "app" {
  launch_configuration = "${aws_launch_configuration.app.id}"
  vpc_zone_identifier = ["${module.vpc.private_subnets}"]
  availability_zones = "${var.vpc_azs}"
  load_balancers    = ["${module.elb_app.elb_name}"]
  health_check_type = "var.asg_app["check_type"]"

  min_size = "${var.asg_app["app_min_size"]}"
  max_size = "${var.asg_app["app_max_size"]}"

  tags = "${local.app_tags}"

}

resource "aws_security_group" "elb_app" {
  name = "${format("%s_elb_sg", var.app_tier_name)}"

  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${local.app_tags}"

}

module "elb_app" {
  source = "terraform-aws-modules/elb/aws"

  name = "${format("%s_elb", var.app_tier_name)}"

  subnets         = ["${module.vpc.private_subnets}"]
  security_groups = ["${aws_security_group.elb_app.id}"]
  internal        = true

  listener = [
    {
      instance_port     = "${var.app_port}"
      instance_protocol = "TCP"
      lb_port           = "${var.app_port}"
      lb_protocol       = "TCP"
    },
  ]

  health_check = [
    {
      target              = "TCP:${var.app_port}"
      interval            = "${var.app_elb_health_check_interval}"
      healthy_threshold   = "${var.app_elb_healthy_threshold}"
      unhealthy_threshold = "${var.app_elb_unhealthy_threshold}"
      timeout             = "${var.app_elb_health_check_timeout}"
    },
  ]

  tags = "${local.app_tags}"

}

variable "app_tier_name" {
  description = "Name of the application tier"
  default = "app-tier"
}

variable "app_key_name" {
  description = "Name of the app public key"
  default = "app-ssh"
}

variable "app_public_key" {
  description = "Path of the public key for application hosts"
  default = "~/.ssh/app_key.pub"
}

variable "app_sg"{
  description = "Name of the application security group"
  default = "app_security_group"
}

variable "app_elb_health_check_interval" {
  description = "Duration between health checks"
  default = 20
}

variable "app_elb_healthy_threshold" {
  description = "Number of checks before an instance is declared healthy"
  default = 2
}

variable "app_elb_unhealthy_threshold" {
  description = "Number of checks before an instance is declared unhealthy"
  default = 2
}

variable "app_elb_health_check_timeout" {
  description = "Interval between checks"
  default = 5
}

variable "app_port" {
  description = "The port on which the application listens for connections"
  default = 8080
}

variable "app_instance_type" {
  description = "The EC2 instance type for the application servers"
  default = "t2.large"
}

variable "asg_app" {
  type = "map"
  description = "ASG configs for app"
  default = {
    "app_min_size" = "2"
	"app_max_size" = "5"
	"check_type" = "EC2"
  }
}
