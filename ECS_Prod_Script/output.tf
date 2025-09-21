output "server_name" {
    value = aws_db_instance.mydb.address
}

output "username" {
    value = aws_db_instance.mydb.username
}

output "password" {
    value = aws_db_instance.mydb.password
    sensitive = true
}

output "db_name" {
    value = aws_db_instance.mydb.db_name
}

output "aws_sm_arf" {
    sensitive = true
    value = aws_secretsmanager_secret.todo_db_secrets.arn
}