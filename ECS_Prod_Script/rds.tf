resource "aws_db_instance" "mydb" {
  engine = "postgres"
  engine_version = "17.2"
  identifier = "mydb"
  username = var.db_username
  password = var.db_password
  db_name = var.db_db
  instance_class = "db.t4g.micro"
  storage_type = "gp2"
  skip_final_snapshot = true
  allocated_storage = 20
  network_type = "IPV4"
  publicly_accessible = false


  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.todo_db_rds_subnet.id
}