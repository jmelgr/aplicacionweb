resource "aws_db_subnet_group" "rds_subnets" {
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier        = "proyecto-postgres"
  engine            = "postgres"
  engine_version    = "16.9"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "appdb"
  username = var.db_username
  password = var.db_password

  multi_az            = true
  storage_type        = "gp3"
  publicly_accessible = false
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "proyecto-postgres"
  }
}
