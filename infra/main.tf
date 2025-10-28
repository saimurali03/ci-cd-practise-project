provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "app" {
  name = "CI-CD-Project"
}
