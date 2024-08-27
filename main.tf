provider "aws" {
  region = "${var.region}"
}

terraform {
  # backend "s3" {}
  cloud {
    organization = "von-herff-gallery"
    workspaces {
      name = "vhg-infra-app"
    }
  }
}

data "terraform_remote_state" "platform" {
  backend = "remote"

  config = {
    organization = "von-herff-gallery"
    workspaces = {
      name = "vhg-infra-platform"
    }
  }
}

# TODO: Remove later, as "teamplate_file" is deprecated
# data "template_file" "ecs_task_definition_template" {
#   template = "${file("task-definition.json")}"

#   vars = {
#     task_definition_name = "${var.ecs_service_name}"
#     ecs_service_name = "${var.ecs_service_name}"
#     docker_image_url = "${var.docker_image_url}"
#     memory = "${var.memory}"
#     docker_container_port = "${var.docker_container_port}"
#     region = "${var.region}"
#   }
# }

resource "aws_ecs_task_definition" "vhgapp_task_definition" {
  # TODO: Remove later, as "teamplate_file" is deprecated
  # container_definitions = "${data.template_file.ecs_task_definition_template.rendered}"

  # TODO: Remove later, as I think the JSON file being fed in, isn't taking. Instead writing the
  # JSON inline with `jsonencode` option instead of `templatefile`
  # container_definitions = templatefile("${path.module}/task-definition.json", {
  #   container_definitions = templatefile("${path.module}/task-definition.json", {
  #   task_definition_name = "${var.ecs_service_name}"
  #   ecs_service_name = "${var.ecs_service_name}"
  #   docker_image_url = "${var.docker_image_url}"
  #   memory = "${var.memory}"
  #   docker_container_port = "${var.docker_container_port}"
  #   region = "${var.region}"
  # })

  # TODO: Remove later if environment varialbes for container_definitions is not needed:
  # environment = [
  #   {
  #     name = "NODE_ENV"
  #     value = "${var.vercel_env}"
  #   },
  #   {
  #     name = "VERCEL_URL"
  #     value = "${var.vercel_url}"
  #   }
  # ]
  container_definitions = jsonencode(
    [
      {
        name = "${var.ecs_service_name}"
        image = "${var.docker_image_url}"
        essential = true
        portMappings = [
          {
            containerPort = "${var.docker_container_port}"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group" = "${var.ecs_service_name}-LogGroup"
            "awslogs-region" = "${var.region}"
            "awslogs-stream-prefix" = "${var.ecs_service_name}-LogGroup-stream"
          }
        }
      }
    ]
  )
  family = "${var.ecs_service_name}"
  cpu = 512
  memory = "${var.memory}"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = "${aws_iam_role.fargate_iam_role.arn}"
  task_role_arn = "${aws_iam_role.fargate_iam_role.arn}"
}

resource "aws_iam_role" "fargate_iam_role" {
  name = "${var.ecs_service_name}-IAM-Role"
  assume_role_policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Sid: "",
        Effect: "Allow"
        Principal: {
          Service: ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
        Action: "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "fargate_iam_role_policy" {
  name = "${var.ecs_service_name}-IAM-Role-Policy"
  role = "${aws_iam_role.fargate_iam_role.id}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect: "Allow"
        Action: [
          "ecs:*",
          "ecr:*",
          "logs:*",
          "cloudwatch:*",
          "elasticloadbalancing:*"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_security_group" "app_security_group" {
  name = "${var.ecs_service_name}-SG"
  description = "Security group for Von Herff Gallery application to communicate in and out"
  vpc_id = "${data.terraform_remote_state.platform.outputs.vpc_id}"

  # TODO: Remove later. Replaced with "aws_vpc_security_group_ingress_rule"
  # ingress = {
  #   from_port = 3000
  #   protocol = "TCP"
  #   to_port = 3000
  #   cidr_blocks = ["${data.terraform_remote_state.platform.outputs.vpc_cidr_block}"]
  # }

  # TODO: Remove later. Replaced with "aws_vpc_security_group_egress_rule"
  # egress = {
  #   from_port = 0
  #   protocol = "-1"
  #   to_port = 0
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "${var.ecs_service_name}-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_security_group_ingress_rule" {
  security_group_id = aws_security_group.app_security_group.id

  from_port = 3000
  ip_protocol = "tcp"
  to_port = 3000
  cidr_ipv4 = "${data.terraform_remote_state.platform.outputs.vpc_cidr_block}"
}

resource "aws_vpc_security_group_egress_rule" "app_security_group_egress_rule" {
  security_group_id = aws_security_group.app_security_group.id

  # TODO: Remove later, as "0" notation for specify "all ports" is deprecated.
  # from_port = 0
  ip_protocol = "-1"
  # TODO: Remove later, as "0" notation for specify "all ports" is deprecated.
  #to_port = 0
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_alb_target_group" "ecs_app_target_group" {
  name = "${var.ecs_service_name}-TG"
  port = "${var.docker_container_port}"
  protocol = "HTTP"
  vpc_id = "${data.terraform_remote_state.platform.outputs.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/actuator/health"
    protocol = "HTTP"
    matcher = "200"
    interval = 60
    timeout = 30
    unhealthy_threshold = "3"
    healthy_threshold = "3"
  }

  tags = {
    Name = "${var.ecs_service_name}-TG"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name = "${var.ecs_service_name}"
  task_definition = "${var.ecs_service_name}"
  desired_count = "${var.desired_task_number}"
  cluster = "${data.terraform_remote_state.platform.outputs.ecs_cluster_name}"
  launch_type = "FARGATE"

  network_configuration {
    subnets = [
      "${data.terraform_remote_state.platform.outputs.ecs_public_subnet_1_id}",
      "${data.terraform_remote_state.platform.outputs.ecs_public_subnet_2_id}",
      "${data.terraform_remote_state.platform.outputs.ecs_public_subnet_3_id}"
    ]
    security_groups = ["${aws_security_group.app_security_group.id}"]
    assign_public_ip = true
  }

  load_balancer {
    container_name = "${var.ecs_service_name}"
    container_port = "${var.docker_container_port}"
    target_group_arn = "${aws_alb_target_group.ecs_app_target_group.arn}"
  }
}

resource "aws_alb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn = "${data.terraform_remote_state.platform.outputs.ecs_alb_listener_arn}"

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.ecs_app_target_group.arn}"
  }

  condition {
    host_header {
      values = ["${lower(var.ecs_service_name)}.${data.terraform_remote_state.platform.outputs.ecs_domain}"]
    }
  }
}

resource "aws_cloudwatch_log_group" "vhgapp_log_group" {
  name = "${var.ecs_service_name}-LogGroup"
}