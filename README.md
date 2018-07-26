
Deploy [Kong](https://konghq.com/kong-community-edition/) to AWS

DONE

- VPC, Subnets, SGs
- ECS Cluster

TODO

- ECS Service
- RDS (postgres)
- LB
- Bastion for Kong Admin

Most terraform modules added as git submodules, cribbed from Terraform community AWS modules:
https://github.com/terraform-aws-modules/

After cloning this, you will need to `git submodule init && git submodule update`
