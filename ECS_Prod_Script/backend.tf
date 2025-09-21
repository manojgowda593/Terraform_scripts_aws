terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-todo"
    key            = "ecs/todo/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
