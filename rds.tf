# RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-RDS-SG"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    description               = "Postgres access from ECS cluster"
    protocol                  = "tcp"
    from_port                 = "5432"
    to_port                   = "5432"
    security_groups           = ["${aws_security_group.ecs_service_kong.id}"]
  }
  egress  {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {

    Name    = "${var.app_name}-RDS-SG"

  } 
}
resource "aws_db_parameter_group" "main" {
  name    = "${var.db_engine}"
  family  = "${var.db_engine}${var.db_engine_version}"

  parameter {
    name         = "autovacuum"
    value        = "1"
    apply_method = "pending-reboot"
  }
}

module "rds" {
  source                    = "terraform-aws-modules/rds/aws"
  identifier                = "${lower(var.app_name)}"  # rds identifier must be lowercase
  name                      = "${var.app_name}"

  engine                    = "${var.db_engine}"
  engine_version            = "${var.db_engine_version}"
  port                      = "${var.db_port}"

  instance_class            = "${var.db_instance_class}"
  allocated_storage         = "${var.db_allocated_storage_gb}"

  maintenance_window        = "${var.db_maintenance_window}"
  backup_window             = "${var.db_backup_window}"

  vpc_security_group_ids    = ["${aws_security_group.rds_sg.id}"]
  subnet_ids                = "${module.vpc.private_subnets}"
  multi_az                  = false
  apply_immediately         = true
  skip_final_snapshot       = true
  iam_database_authentication_enabled = true

  parameter_group_name      = "${var.db_engine}"

  username                  = "${var.db_username}"
  password                  = "${var.db_password}"
}

