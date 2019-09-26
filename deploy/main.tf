resource "aws_security_group" "paystack-server" {
  name        = "paystack-sg"
  description = "Allow incoming traffic on 80"
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

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["197.255.52.86/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    cidr_blocks = ["197.255.52.86/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 27017
    to_port     = 27017
    cidr_blocks = ["197.255.52.86/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["197.255.52.86/32"]
  }



}

resource "aws_instance" "paystack-server" {
  ami                         = "${lookup(var.ec2_amis, var.aws_region)}"
  associate_public_ip_address = true
  count                       = "${length(var.azs)}"
  depends_on                  = ["aws_subnet.public"]
  instance_type               = "t2.micro"
  key_name                    = "paystack"
  subnet_id                   = "${element(data.aws_subnet_ids.public.ids, count.index)}"
  user_data                   = "${file("user_data.sh")}"

  vpc_security_group_ids = ["${aws_security_group.paystack-server.id}"]

  tags {
    Name = "Paystack-app-server ${count.index}"
  }
}




resource "aws_route53_health_check" "health_check" {
  fqdn              = "${aws_elb.paystack-app-lb.dns_name}"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "paystack-health-check"
  }
}


resource "aws_cloudwatch_metric_alarm" "alarm" {
  depends_on          = ["aws_route53_health_check.health_check"]
  alarm_name          = "paystack_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "AppHealthCheck"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "This metric monitors application"

  dimensions = {
    HealthCheckId = "${aws_route53_health_check.health_check.id}"
  }
}


resource "aws_key_pair" "paystack_key" {
  key_name   = "paystack_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0GZLCdMrUoQmVG+r3Kk8hWy8lsG3EFIU2n1vQQya35zfQOKks/u8ijjzW2DD5X4nCtMzbdiAMwrzZp2BvbLMzjZluL2auLKerL8GX/iu3HPJ9qSXNDLAt40m8O/6W+AI9O9u0rNGLJu98rdZx35n7rbHHXrV5H4+4lJl/IXF8q2DQ3tggmeec7pmFJMKH64fnvRmOvEZcUDBwOSN1JFjpmgRE9sHBlGa/iQdGRKFfosuFnHGHAqEZTfWklsOGHzojd7MF+dTIK3ltBBPO47jjnOrQCkOJ4W0exPaitMEFIOuhE5EmrsGZVXGtkHbTGuNu5dvtl6oSlgMQxzSKfD9n mac@macs-MacBook-Pro-2.local"
}
