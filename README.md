# Overview

Terraform to deploy [Kong](https://konghq.com/kong-community-edition/) to AWS

![AWS](https://pbs.twimg.com/profile_images/476765659670384641/JkbHgnsy.png) ![Plus](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQXkwy0aF04AY4518KijPrsS-7q-TXR0klp31orsq9XpBqQKXCFsg) ![Kong](https://res-5.cloudinary.com/crunchbase-production/image/upload/c_lpad,h_256,w_256,f_auto,q_auto:eco/ybimx0g1qmd9ynruwosf)

# Functionality

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

## To Do

- Kong access RDS (currently container just constantly restarts)
- Load Balancer
- Bastion for Kong Admin

# Usage

Per standard Terraform best prac - creds expected to be in environment or instance parameter

e.g. my dev instance has IAM profile "provisioner" which runs this

The only var not specified in variables.tf is the database pasword:

`terraform apply -var 'db_password=myawesomepassword'`

(or leaving it blank will just prompt)

# Dependencies

Most terraform modules added as git submodules, cribbed from Terraform community AWS modules: https://github.com/terraform-aws-modules/

After cloning this, you will need to `git submodule init && git submodule update` to get them
