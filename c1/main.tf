# Providing the backend for terraform
terraform {
  backend "s3" {
    bucket         = "${var.backend_bucket}"
    key            = "${var.file_name}"
    region         = "${var.aws_region}"
    dynamodb_table = "${var.backend_table}"
  }
}

locals {
  vpc_tags = {
    "Name" = "${var.vpc_name}"
	"App" = "${var.app_name}"
	"Env" = "${var.env_name}"
  }
}

locals {
  network_acls = {
    public_inbound = [
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "${var.corp_ips}"
      },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,0)}"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,1)}"
      },	  
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "${var.corp_ips}"
      },
    ]
	private_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "${var.vpc_public_subnets}"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,0)}"
      },
	  {
        rule_number = 120
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,1)}"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,0)}"
      },
	  {
        rule_number = 140
        rule_action = "allow"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,1)}"
      },	  
      {
        rule_number = 150
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_database_subnets,0)}"
      },		  
	]
	private_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "${var.vpc_public_subnets}"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,0)}"
      },
	  {
        rule_number = 120
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,1)}"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,0)}"
      },
	  {
        rule_number = 140
        rule_action = "allow"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,1)}"
      },	  
      {
        rule_number = 150
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_database_subnets,0)}"
      },	  
    ]
	db_inbound = [	
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,0)}"
      },
	  {
	    rule_number = 110
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,1)}"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_database_subnets,0)}"
      },
	  {
	    rule_number = 130
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_database_subnets,1)}"
      },	  
    ]
	db_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,0)}"
      },
	  {
	    rule_number = 110
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_private_subnets,1)}"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_database_subnets,0)}"
      },
	  {
	    rule_number = 130
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = "${element(var.vpc_database_subnets,1)}"
      },	  
    ]
  }
}

# Selecting the desired cloud provider

provider "aws" {
region = "${var.aws_region}"
}

# Using the vpc module to create the vpc, subnets and nat gateway

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.vpc_name}"
  azs = "${var.vpc_azs}"
  cidr = "${var.vpc_cidr}"

  public_subnets = "${var.vpc_public_subnets}"
  private_subnets = "${var.vpc_private_subnets}"
  database_subnets = "${var.vpc_database_subnets}"

  enable_nat_gateway = "${var.vpc_enable_nat_gateway}"
  single_nat_gateway = "${var.vpc_single_nat_gateway}"
  one_nat_gateway_per_az = "${var.vpc_one_nat_gateway_per_az}"
  public_dedicated_network_acl   = true
  public_inbound_acl_rules       = local.network_acls["public_inbound"]
  public_outbound_acl_rules      = local.network_acls["public_outbound"]
  private_dedicated_network_acl   = true
  private_inbound_acl_rules       = local.network_acls["private_inbound"])
  private_outbound_acl_rules      = local.network_acls["private_outbound"])
  database_dedicated_network_acl  = true
  database_inbound_acl_rules      = local.network_acls["db_inbound"])
  database_outbound_acl_rules     = local.network_acls["db_outbound"])  

  tags = "${local.vpc_tags}" 
}

variable "backend_bucket" {
  description = "The name of your bucket where the tfstate file will be stored"
  default     = "terraform_backend_bucket"
}

variable "file_name" {
  description = "The name of key to be stored in the bucket"
  default     = "terraform.tfstate"
}

variable "aws_region" {
  description = "The aws region"
  default     = "us-east-1"
}

variable "backend_table" {
  description = "The name of dynamo DB table"
  default     = "terraform_backend_table"
}

variable "vpc_name" {
  description = "The name of your VPC"
  default     = "challenge1"
}

variable "app_name" {
  description = "The name of your application"
  default     = "challenge1_3_tier"
}

variable "env_name" {
  description = "The name of the environment"
  default     = "production"
}
  
# VPC Module Variables from Terraform Module Repository:
variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = ["10.0.1.0/24"]
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_database_subnets" {
  type        = "list"
  description = "A list of database subnets"
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}

variable "vpc_one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = false
}