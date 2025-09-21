
resource "aws_ecs_cluster" "todo-cluster" {
  name = "todo"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_task_definition" "todo-task" {
  family                   = "todo-task-definition"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "todo"
      image     = "${var.docker_username}/${var.image_name}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${aws_secretsmanager_secret.todo_db_secrets.arn}:username::"
        },
        {
          name      = "DB_ENGINE"
          valueFrom = "${aws_secretsmanager_secret.todo_db_secrets.arn}:engine::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.todo_db_secrets.arn}:password::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.todo_db_secrets.arn}:db::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.todo_db_secrets.arn}:server_name::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "${aws_secretsmanager_secret.todo_db_secrets.arn}:port::"
        }
      ]


      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/todo"
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}



resource "aws_ecs_service" "todo-service" {
  name            = "todo-service"
  cluster         = aws_ecs_cluster.todo-cluster.id
  task_definition = aws_ecs_task_definition.todo-task.id
  desired_count   = 1
  launch_type     = "FARGATE"
  # iam_role        = aws_iam_role.ecsTaskExecutionRole.arn
  network_configuration {
    subnets = [aws_subnet.public_sub.id, aws_subnet.public_sub_2.id]
    security_groups = [ aws_security_group.ecs_sg.id ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.todo_target_group.arn
    container_name   = "todo"
    container_port   = 8000
  }
}


resource "aws_cloudwatch_log_group" "ecs_todo" {
  name              = "/ecs/todo"
  retention_in_days = 7
}
 