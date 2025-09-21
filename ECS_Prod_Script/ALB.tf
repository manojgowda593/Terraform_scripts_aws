resource "aws_alb" "todo-alb" {
  name = "todo-alb"
  subnets = [aws_subnet.public_sub.id, aws_subnet.public_sub_2.id]
  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "todo-alb"
  }
}

resource "aws_lb_target_group" "todo_target_group" {
  name        = "todo-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.todo-vpc.id

  health_check {
    path                = "/health/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "todo-listener" {
  load_balancer_arn = aws_alb.todo-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo_target_group.arn
  }
}