1. c1 folder contains the solution of challenge1. 

Terraform has been used as the tool for writing infrastructure as a code.
An architecture diagram is included in the c1 folder, In order to maintain readability the code has been divided into main.tf, appservers.tf, webservers.tf, db.tf, 
bastion.tf and outputs.tf. Extensive use of input variables is done to avoid hard coding, Default values have been assigned to the input variables and these values can be 
overridden through terraform.tfvars file. terraform.tfstate file is stored in the s3 bucket and state locking is also done via the dynamo DB.
As the number of input variables are large, instead of putting them in a single input.tf file the relevant input variables are present in the respective tf script.

The3-tier architecture consists of 1 public subnet, 2 private subnets and 2 db subnets. Web servers are kept in the private subnets in order to safeguard them from any potential DDOS.
Public load balancer is internet facing and receives the request, the backend pool of public lb contains web servers autoscaling group spread across multiple availability zones. Web servers then forwards the request to the 
 internal load balancer. The internal lb backend pool contains app servers autoscaling group spread across multiple availability zones. The app servers interacts with aws rds(postgres) for db related tasks.

The web servers asg and app servers asg are using custom amis in thier launch configuration. 
The web servers ami contains relevant linux packages like nginx/apache installed and configured.
The app servers ami contains relevant linux packages and application code.
These amis are created via packer and are uploaded to aws.
Bastion server is added for maintenance/debugging purpose, It can only be accessed from corporate ips for enhanced security.


2. c2 folder contains the solution of challenge2.

challenge2.py is used to fetch metadata from aws instance using ec2 instance metadata service (IMDS v2)
To fetch the entire metadata ==> meta_data_retriever()
To fetch metadata with specific key ==> specific_meta_info("meta-data/ami-id")


3. c3 folder contains the solution of challenge3.

challenge3.py is used to output the value of nested keys, I have created 2 approaches :
	approach1 --> get_value(obj, keys) where obj is the name of dictionary and keys is / separated dictionary key string.
				  
				  obj = {"a":{"b":{"c":"d"}}}
				  get_value(obj, "a/b/c")

	approach2 --> get_value_a2(obj, *keys) where obj is the name of dictionary and keys is a variable argument that contains keys.
	
				  obj = {"a":{"b":{"c":"d"}}}
				  get_value(obj, "a","b","c")
				  
	Both approaches provides the same result, the only difference is the way arguments are fed to them.