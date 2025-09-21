resource "aws_secretsmanager_secret" "todo_db_secrets" {
    name = "todo-rds-secrets"
}

resource "aws_secretsmanager_secret_version" "db_secreat_vlaue" {
  secret_id = aws_secretsmanager_secret.todo_db_secrets.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    db = var.db_db
    port = 5432
    engine = "django.db.backends.postgresql"
    server_name = aws_db_instance.mydb.address
  })
  depends_on = [aws_db_instance.mydb]
}