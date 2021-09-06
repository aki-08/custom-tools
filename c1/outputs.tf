# VPC ID
output "vpc_id" {
description = "The ID of the VPC"
value       = module.vpc.vpc_id
}

# CIDR Block of VPC
output "vpc_cidr_block" {
description = "The CIDR block of the VPC"
value       = module.vpc.vpc_cidr_block
}

# List of the private subnets of the VPC
output "private_subnets" {
description = "List of IDs of private subnets"
value       = module.vpc.private_subnets
}

# List of the public subnets of the VPC
output "public_subnets" {
description = "List of IDs of public subnets"
value       = module.vpc.public_subnets
}

# List of the database subnets of the VPC
output "database_subnets" {
description = "List of IDs of db subnets"
value       = module.vpc.database_subnets
}

# NAT gateway public ip
output "nat_public_ip" {
description = "List of public Elastic IPs created for AWS NAT Gateway"
value       = module.vpc.nat_public_ips
}

# List of availability zones
output "azs" {
description = "A list of availability zones spefified as argument to this module"
value       = module.vpc.azs
}

# Public IP of the bastion host
output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

# DNS name of public load balancer
output "bastion_public_ip" {
  value = "${module.elb_web.elb_dns_name}"
}

# DNS name of internal load balancer
output "bastion_public_ip" {
  value = "${module.elb_app.elb_dns_name}"
}

