# Overview

Deploy [Kong](https://konghq.com/kong-community-edition/) to AWS, with RDS (Postgres), in highly-available multi-AZ and secure config

![Architecture](doc/img/architecture.png)

Note: Service Discovery currently uses [ECS Service Discovery](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html)

# Disclaimer
The architecture of Kong on AWS ECS is fairly basic. I stumbled upon [this article](https://medium.com/@nick.p.doyle/deploying-kong-to-aws-elastic-container-service-with-terraform-9de83d7e21) by Nick Doyle while I was googling how to deploy Kong on AWS ECS. I thought it would be a good chance to learn terraform because I've never used it so far and it would be easier than using Cloudformation alone or Cloudformation with say Ansible and Make.
Most of the code was done by [Nick Doyle](https://bitbucket.org/%7B5d0aaa3a-ab6b-4079-8249-6632d8831d28%7D/) I only cleaned up the code as it wasn't working with the latest Terraform version, removed git submodules because I hate them.



# Deployment Instructions

1. Clone this repo
2. [Install terraform](https://www.terraform.io/intro/getting-started/install.html)
3. Update variables.tf according to your environment
4. Create an ssh key for bastion and ECS instances if it doesn't exist with the name you specify [here](https://github.com/mdesouky/AWS-Kong-ECS/blob/master/variables.tf#L7-L9)
5. `terraform init`
6. `terraform apply`

# Functionality

## ECS Services

- Kong Gateway
    - port 8000 (standard API Gateway) open from ALB and Bastion (kong.ecs.local)
    - port 8001 (admin API) open from Kong Dashboard container
- Kong Dashboard
    - connects to kong ADMIN API port 8001
    - port 8080 (standard HTTP interface) open from Bastion (kong-dash.ecs.local)
- Nyan
    - shows nyan cat
    - port 80 open from Kong Gateway (nyan.ecs.local)

## Bastion Host

Admin interfaces should arguably only ever be available over VPN or via bastion. To this end a basic bastion is provided, see bastion.tf.

bastion host is not (currently) HA, sits in public subnet 1.

To access kong admin api:

`ssh -N -L 8001:8001 ubuntu@52.64.239.9`

(where '52.64.239.9' is IP of the bastion host)

Then connect to localhost:8001

## Kong Docker Image

### Configured from SSM Parameters

The standard [Kong docker image](https://hub.docker.com/_/kong/) takes configuration from environment variables. Deploying this would tie Kong's configuration to the task definition which has two main disadvantages:

- Configuration updates require deploying new task definition
- Secrets must be stored in task definition
- No canonical secret/config store

For these reasons it was decided to extend the standard Kong 0.14.0-alpine image to optionally take its config from SSM parameters.

This was done by installing awscli, jq and curl in the image, and modifying docker-entrypoint.sh to use these to (if provided) obtain the config and override Kong's default environment variables.

The SSM parameter names are passed in as environment variables at 'docker run' time i.e. container definition (see main.tf resource "aws_ecs_task_definition"). By default these are all SecureStrings nested under prefix "/dev/kong/"

The parameters are set at terraform apply-time - see main.tf e.g. resource "aws_ssm_parameter" "db_username"

The [docker image with Kong taking configuration from SSM parameter store is on DockerHub](https://hub.docker.com/r/rdkls/kong_ssm)

## Kong Dashboard
[Docker image for the task definition is on DockerHub](https://hub.docker.com/r/pgbi/kong-dashboard)

This is the [Dashboard on Github](https://github.com/PGBI/kong-dashboard)

### Permissions

This setup also requires that the running container (task) have permission to read and decrypt the SSM Parameters.

This is done using AWS' "task_role" concept, which assigns an IAM role to the task by passing in environment variable "AWS_CONTAINER_CREDENTIALS_RELATIVE_URI", which is used to obtain assumed role for the container.

Such approach means the container instance itself, nor any other container tasks running on same instance, can access these secrets.

This IAM work took quite some time to debug; had to modify entrypoint/command in deployed task definition, to just e.g. "/usr/bin/env", or "/usr/bin/aws ssm get-parameter ..", then ssh to the docker host/container instance and view logs (or via cloudwatch, but that's slower)

The IAM role is created by custom module in modules/ecs_task_iam/main.tf

This module takes variables from the rest of the config (changing e.g. prefix/ssm parameter name in toplevel variables.tf will also update IAM policy as you might hope :), and outputs the role ARN for the task definition to use.

### Registry & Source

The container is hosted on [Docker Hub](https://hub.docker.com/r/rdkls/kong_ssm/), and the source on [BitBucket](https://bitbucket.org/nick_doyle/docker_kong_ssm/)

## Done

- VPC
    - Subnets public & private in 3AZs
- SGs for
    - Kong app (on ecs)
    - RDS, inbound only from public subnet (issues getting TF to do by SG)
- IAM roles for
    - ECS instance
    - ECS service (the running containers themselves, with only SSM read)
- ECS Cluster
    - ASG & LC
    - ECS Instances restricted according to best prac - no privileged containers & no metadata from containers
- ECS Service for Kong
    - TODO rds access
- RDS (postgres)
- SSM Parameter Store
    - Storing config/secrets (as SecureString)
- Kong access RDS
- Load Balancer
- Bastion for Kong Admin
- ECS Service Discovery

# Cost

Major costs:

- Service discovery requires each task to have an ENI hence m5.xlarge used for ECS cluster instance
- ALB

![Budget](doc/img/budget.png)

# References:
1. [Nick Doyle's Post on Medium](https://medium.com/@nick.p.doyle/deploying-kong-to-aws-elastic-container-service-with-terraform-9de83d7e21)
2. [Nick Doyle's Repo on Bitbucket](https://bitbucket.org/nick_doyle/kong_aws_terraform/src/master/)
3. [Terraform AWS Modules](https://github.com/terraform-aws-modules)

# What I have Improved over the already existing code
1. Removed git submodules
2. Fixed syntax errors with the latest Terraform version
3. 


# What I would have done if I had more time
1. Use AWS Session Manager and get rid of the bastion
2. Add Tag and Drain Lambdas to hookup ECS with Autoscaling properly to prevent service outages during autoscaling events
3. Used IAM authentication for Kong's access to RDS instead of managing secrets
4. ECS is fucked, need to sort out the ecs cluster module and the roles for tasks and stuff everything is broken
