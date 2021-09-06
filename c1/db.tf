# Creating security group for the rds instance

locals {
  db_tags = {
    "Name" = "${var.rds_configs["db_identifier"]}"
	"App" = "${var.app_name}"
	"Env" = "${var.env_name}"
  }
}

resource "aws_security_group" "rds" {
  name = "${format("%s_sg", var.rds_configs["db_identifier"])}"
  vpc_id = "${module.vpc.vpc_id}"
  ingress {
    from_port   = "${var.db_port}"
    to_port     = "${var.db_port}"
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.private_subnets_cidr_blocks}"]
  }
  
  tags = "${local.db_tags}"

}

# Using rds module in the terraform registry to create the rds instance resource

module "master_db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "${var.rds_configs["db_identifier"]}"
  engine            = "${var.rds_configs["db_engine"]}"
  engine_version    = "${var.rds_configs["db_engine_ver"]}"
  instance_class    = "${var.rds_configs["db_instance_class"]}"
  allocated_storage = "${var.rds_configs["db_storage"]}"
  name =     "${var.db_name}"
  username = "${var.db_username}"
  password = "${var.db_password}"
  port     = "${var.rds_configs["db_port"]}"
  multi_az               = true
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  maintenance_window = "${var.rds_configs["db_maintenance_window"]}"
  backup_window      = "${var.rds_configs["db_backup_window"]}"
  backup_retention_period = "${var.rds_configs["db_backup_retention_period"]}"
  subnet_ids = ["${module.vpc.database_subnets}"]
  family = "${var.rds_configs["db_family"]}"
  tags = "${local.db_tags}"

}

# Creating a replica for the master rds database server

module "replica_db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "${var.rds_configs["db_identifier"]}-replica"
  replicate_source_db = module.master_db.db_instance_id
  engine            = "${var.rds_configs["db_engine"]}"
  engine_version    = "${var.rds_configs["db_engine_ver"]}"
  instance_class    = "${var.rds_configs["db_instance_class"]}"
  allocated_storage = "${var.rds_configs["db_storage"]}"
  port     = "${var.rds_configs["db_port"]}"
  multi_az  = false
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  family = "${var.rds_configs["db_family"]}"
  maintenance_window = "${var.rds_configs["db_maintenance_window_replica"]}"
  backup_window = "${var.rds_configs["db_backup_window"]}"
  subnet_ids = ["${module.vpc.database_subnets}"]
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  tags = "${local.db_tags}"
}


variable "db_name" {
  description = "The DB name to create"
  sensitive   = true
}

variable "db_username" {
  description = "Username for the master DB user"
  sensitive   = true
}

variable "db_password" {
  description = "Password for the master DB user"
  sensitive   = true
}

variable "rds_configs" {
  type = "map"
  description = "RDS postgres configs"
  default = {
    "db_identifier" = "rds-prd"
	"db_engine" = "postgres"
	"db_engine_ver" = "9.6.3"
	"db_instance_class" = "db.t2.xlarge"
	"db_storage" = "500"
	"db_family" = "postgres9.6"
    "db_maintenance_window" = "Fri:02:00-Fri:04:00"
	"db_maintenance_window_replica" = "Sun:02:00-Sun:04:00"
	"db_backup_window" = "09:00-10:00"
	"db_port" = "5432"
	"db_backup_retention_period" = "1"
  }
}