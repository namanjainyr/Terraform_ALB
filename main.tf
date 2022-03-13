provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "svc" {
    ami = "ami-033b95fb8079dc481"
    instance_type = "t2.micro"
}

resource "aws_instance" "svc2" {
    ami = "ami-033b95fb8079dc481"
    instance_type = "t2.micro"
}

resource "aws_alb" "alb" {
  name      = "${var.alb_name}"
  subnets = ["subnet-98ca5efe","subnet-038b1a5c"]
  tags = {
    Name    = "${var.alb_name}"
  }
}



resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "${var.alb_listener_port}"
  protocol          = "${var.alb_listener_protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  #depends_on   = ["aws_alb_target_group.alb_target_group"]
  listener_arn = "${aws_alb_listener.alb_listener.arn}" 
  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
  }
  condition {
    query_string {
      key   = "s"
      value = "s"
    }
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "${var.target_group_name}"
  port     = "${var.svc_port}"
  protocol = "HTTP"
  vpc_id = "vpc-c909a8b4"
  tags = {
    name = "${var.target_group_name}"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "${var.target_group_path}"
    port                = "${var.target_group_port}"
  }
}

#Instance Attachment
resource "aws_alb_target_group_attachment" "svc_physical_external" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.svc.id}"
  port             = 8080
}

resource "aws_alb_target_group_attachment" "svc_physical_external_2" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.svc2.id}"
  port             = 8080
}
