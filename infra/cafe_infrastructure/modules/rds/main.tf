#Configuring the Database Subnet Group
resource "aws_db_subnet_group" "cafe_db_subnet_group" {
  name = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    "Name" = "${var.db_identifier}-subnet-group"
  }
}

#Configuring the Database Instance
resource "aws_db_instance" "cafe_db" {
  identifier = var.db_identifier
  engine =  "mysql"
  engine_version =  "8.0"
  instance_class =  var.db_instance_class
  allocated_storage =  var.db_allocated_storage
  storage_type =  "gp3"
  db_name =  var.db_name
  username =  var.db_username
  password =  var.db_password
  db_subnet_group_name = aws_db_subnet_group.cafe_db_subnet_group.name
  vpc_security_group_ids = var.db_security_group_id
  skip_final_snapshot = true
  # deletion_protection = true <- Commented out to facilitate destruction, BUT is necessary in real environments
  # final_snapshot_identifier = "${var.db_identifier}-final-snapshot"
  # backup_retention_period = 7
  # backup_window = "03:00-04:00"
  publicly_accessible =  false
  multi_az =  true
  storage_encrypted = true
  

  tags = {
    "Name" = "cafe_RDS_MySQL"
  }
}