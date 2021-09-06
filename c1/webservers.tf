# Getting the custom ami created for web server

locals {
  web_tags = {
    "Name" = "${var.web_tier_name}"
	"App" = "${var.app_name}"
	"Env" = "${var.env_name}"
  }
}

data "aws_ami" "web-ami" {
  most_recent = true
  owners      = ["self"]
  
  filter {
    name   = "name"
    values = ["webservers-ami-*"]
  }
}

# Creating security group, launch configuration, autoscaling group and public load balancer for web servers

resource "aws_security_group" "web" {
  name = "${var.web_sg}"
  vpc_id = "${module.vpc.vpc_id}"
  
  dynamic "ingress" {
    for_each = var.web_ports
	iterator = wport
    content {
      from_port   = wport.value
      to_port     = wport.value
      protocol    = "tcp"
      cidr_blocks = ["${module.vpc.public_subnets_cidr_blocks}", "${module.vpc.private_subnets_cidr_blocks}"]
    }
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

  tags = "${local.web_tags}"

}

resource "aws_key_pair" "web_key" {
  key_name = "${var.web_key_name}"
  public_key = "${file(var.web_public_key)}"
}

resource "aws_launch_configuration" "web" {
  image_id        = "${data.aws_ami.web-ami.name}"
  instance_type   = "${var.web_instance_type}"
  security_groups = ["${aws_security_group.web.id}"]
  key_name = "${aws_key_pair.web_key.key_name}"
  name_prefix = "${var.web_tier_name}-vm-"
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "web" {
  launch_configuration = "${aws_launch_configuration.web.id}"
  vpc_zone_identifier = ["${module.vpc.private_subnets}"]
  availability_zones = "${var.vpc_azs}"
  load_balancers    = ["${module.elb_web.elb_name}"]
  health_check_type = "var.asg_web["check_type"]"
  min_size = "${var.asg_web["web_min_size"]}"
  max_size = "${var.asg_web["web_max_size"]}"
  tags = "${local.web_tags}"

}

resource "aws_security_group" "elb_web" {
  name = "${format("%s_elb_sg", var.web_tier_name)}"

  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.web_port}"
    to_port     = "${var.web_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${local.web_tags}"
}

resource "aws_route53_zone" "r53" {
  name          = "${var.domain_name}"
  force_destroy = true
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"

  zone_id = aws_route53_zone.r53.zone_id

  domain_name               = "${var.domain_name}"
  subject_alternative_names = ["*.${var.domain_name}"]

  wait_for_validation = true
}

module "elb_web" {
  source = "terraform-aws-modules/elb/aws"

  name = "${format("%s_elb", var.web_tier_name)}"

  subnets         = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.elb_web.id}"]
  internal        = false

  listener = [
    {
      instance_port     = "${element(var.web_ports,0)}"
      instance_protocol = "HTTP"
      lb_port           = "${element(var.web_ports,1)}"
      lb_protocol       = "HTTPS"
	  ssl_certificate_id = module.acm.acm_certificate_arn
    },
  ]

  health_check = [
    {
      target              = "HTTP:${element(var.web_ports,0)}/"
      interval            = "${var.web_elb_health_check_interval}"
      healthy_threshold   = "${var.web_elb_healthy_threshold}"
      unhealthy_threshold = "${var.web_elb_unhealthy_threshold}"
      timeout             = "${var.web_elb_health_check_timeout}"
    },
  ]

  tags = "${local.web_tags}"

}

variable "web_tier_name" {
  description = "Name of the web tier"
  default = "web-tier"
}

variable "web_key_name" {
  description = "Name of the web public key"
  default = "web-ssh"
}

variable "web_public_key" {
  description = "Path of the public key for web hosts"
  default = "~/.ssh/web_key.pub"
}

variable "ssh_port"{
  description = "Port for ssh"
  default = 22
}

variable "domain_name" {
  description = "Domain name of the application"
  default = "challenge1.com"
}


variable "web_sg"{
  description = "Name of the web security group"
  default = "web_security_group"
}

variable "web_ports" {
  description = "The list of ports to open"
  type = list(number)
  default = [80, 443]
}

variable "web_instance_type" {
  description = "The EC2 instance type for the web servers"
  default = "t2.large"
}

variable "asg_web" {
  type = "map"
  description = "ASG configs for web"
  default = {
    "web_min_size" = "2"
	"web_max_size" = "3"
	"check_type" = "EC2"
  }
}

variable "web_elb_health_check_interval" {
  description = "Duration between health checks"
  default = 20
}

variable "web_elb_healthy_threshold" {
  description = "Number of checks before an instance is declared healthy"
  default = 2
}

variable "web_elb_unhealthy_threshold" {
  description = "Number of checks before an instance is declared unhealthy"
  default = 2
}

variable "web_elb_health_check_timeout" {
  description = "Interval between checks"
  default = 5
}
