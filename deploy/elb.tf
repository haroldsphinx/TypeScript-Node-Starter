resource "aws_security_group" "paystack-app" {
  name        = "paystack-app-sg"
  description = "Inblound for webserver"
  vpc_id      = "${aws_vpc.public.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# classic load balancer
resource "aws_elb" "paystack-app-lb" {
  name                      = "paystack-app-lb"
  cross_zone_load_balancing = true
  subnets                   = ["${data.aws_subnet_ids.public.ids}"]

  #health check settings
  health_check {
    unhealthy_threshold = 2
    healthy_threshold   = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 20
  }

  instances = [
    "${aws_instance.paystack-server.*.id}",
  ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  security_groups = [
    "${aws_security_group.paystack-app.id}",
  ]
}

# output the load balancer unhealthy_threshold
output "url" {
  value = "http://${aws_elb.paystack-app-lb.dns_name}"
}
