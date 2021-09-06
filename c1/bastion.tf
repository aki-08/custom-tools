# Creating bastion host and security group for bastion host

locals {
  bastion_tags = {
    "Name" = "${var.bastion_name}"
	"App" = "${var.app_name}"
	"Env" = "${var.env_name}"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.amazon-linux-2.name}"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.bastion-sg.name}"]
  associate_public_ip_address = true
  subnet_id                   = "${element(module.vpc.public_subnets,0)}"
  tags = "${local.bastion_tags}" 
}

resource "aws_security_group" "bastion-sg" {
  name   = "${format("%s_sg", var.bastion_name)}}"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.corp_ips}"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = "${local.bastion_tags}" 
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.bastion_key_name}"
  public_key = "${file(var.bastion_public_key_path)}"
}

variable "bastion_name" {
  description = "Name of the bastion server"
  default = "challenge1-app-bastion"
}

variable "bastion_public_key_path" {
  description = "Path of the public key for bastion host"
  default = "~/.ssh/bastion_host.pub"
}

variable "bastion_key_name" {
  description = "Name of the bastion public key"
  default = "bastion-ssh"
}

variable "bastion_sg" {
  description = "Name of the bastion server security group"
  default = "bastion_security_group"
}

variable "corp_ips" {
  description = "List of corporate ips to allow ssh"
  type = list(string)
  default = ["213.34.56.78/32"]
}