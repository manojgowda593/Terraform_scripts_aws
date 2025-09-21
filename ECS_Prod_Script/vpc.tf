resource "aws_vpc" "todo-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "todo-vpc"
  }
}

resource "aws_subnet" "public_sub" {
  vpc_id = aws_vpc.todo-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "public_subnet_ecs_todo"
  }
}

resource "aws_subnet" "public_sub_2" {
  vpc_id = aws_vpc.todo-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "public_subnet_ecs_todo_2"
  }
}

resource "aws_subnet" "private_sub_1" {
  vpc_id = aws_vpc.todo-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private_subnet_rds_todo_1"
  }
}

resource "aws_subnet" "private_sub_2" {
  vpc_id = aws_vpc.todo-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private_subnet_rds_todo_2"
  }
}

resource "aws_internet_gateway" "todo_igw" {
  vpc_id = aws_vpc.todo-vpc.id

  tags = {
    Name = "todo_igw"
  }
}

resource "aws_eip" "nat_ip" {
  domain = "vpc"

  tags = {
    Name = "todo_eip"
  }
}

resource "aws_nat_gateway" "todo_nat_gateway" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id = aws_subnet.public_sub.id

  tags = {
    Name = "todo_nat"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.todo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.todo_igw.id
  }

  tags = {
    Name = "public_route"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.todo-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.todo_nat_gateway.id
  }

  tags = {
    Name = "private_route"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  subnet_id = aws_subnet.public_sub.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_subnet_asso_1" {
  subnet_id = aws_subnet.public_sub_2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_subnet_asso_2" {
  subnet_id = aws_subnet.private_sub_1.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "private_subnet_asso" {
  subnet_id = aws_subnet.private_sub_2.id
  route_table_id = aws_route_table.private_route.id
}


# Security group

resource "aws_security_group" "alb_sg" {
  name = "alb_security_group"
  description = "For ALB (public)"
  vpc_id = aws_vpc.todo-vpc.id
  tags = {
    Name = "alb_sg"
  }
}

resource "aws_security_group_rule" "alb_allow_80" {
  type = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 80
  protocol = "tcp"
  to_port = 80
}

resource "aws_security_group_rule" "all_out_alb" {
  security_group_id = aws_security_group.alb_sg.id
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}

# resource "aws_security_group_rule" "alb_allow_8000" {
#   type = "ingress"
#   security_group_id = aws_security_group.alb_sg.id
#   cidr_blocks = ["0.0.0.0/0"]
#   from_port = 8000
#   protocol = "tcp"
#   to_port = 8000
# }


resource "aws_security_group" "ecs_sg" {
  name = "ecs_security group"
  description = "For ecs (public)"
  vpc_id = aws_vpc.todo-vpc.id

  tags = {
    Name = "ecs_sg"
  }
}

resource "aws_security_group_rule" "public_80" {
  type = "ingress"
  security_group_id = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  from_port = 80
  protocol = "tcp"
  to_port = 80
}

resource "aws_security_group_rule" "public_443" {
  type = "ingress"
  security_group_id = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  from_port = 443
  protocol = "tcp"
  to_port = 443
}

resource "aws_security_group_rule" "public_8000" {
  type = "ingress"
  security_group_id = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  from_port = 8000
  protocol = "tcp"
  to_port = 8000
}

resource "aws_security_group_rule" "all_out" {
  security_group_id = aws_security_group.ecs_sg.id
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.todo-vpc.id
  name = "rds sg"
  description = "rds private sg"

  tags = {
    Name = "rds_sg_private"
  }
}

resource "aws_security_group_rule" "allow_5432" {
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.ecs_sg.id
  type = "ingress"
  from_port = 5432
  protocol = "tcp"
  to_port = 5432
}

resource "aws_security_group_rule" "all_out_rds" {
  type = "egress"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "-1"
  from_port = 0
  to_port = 0
}

resource "aws_db_subnet_group" "todo_db_rds_subnet" {
  name = "todo-rds-subnet"
  subnet_ids = [ 
    aws_subnet.private_sub_1.id,
    aws_subnet.private_sub_2.id
   ]

   tags = {
    Name = "todo_db_subnerts"
   }
}