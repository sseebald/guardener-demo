// DEMO FIXTURE. Upstream images on purpose. See ../README.md.
//
// Terraform is the asymmetric case between the two Guardener features:
//
//   Image Suggestions  -> reads this file and REPORTS the images, but never
//                         offers a one-click suggested change.
//   Image Migration    -> does not read this file at all.
//
// To find the images hiding in files like this one, run:
//   chainctl images discover

terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS region for the Northwind workloads"
  default     = "us-west-2"
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "northwind-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = "node:20-alpine"
      essential = true
      command   = ["node", "worker.js"]
    },
    {
      name      = "otel-collector"
      image     = "otel/opentelemetry-collector-contrib:0.108.0"
      essential = false
    }
  ])
}

resource "aws_ecs_task_definition" "migrate" {
  family                   = "northwind-migrate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "flyway"
      image     = "flyway/flyway:10.17"
      essential = true
      command   = ["migrate"]
    }
  ])
}
