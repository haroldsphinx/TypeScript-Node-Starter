resource "aws_vpc" "public" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "Paystack-vpc"
  }
}

# 0.0.0.0/0
resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.public.id}"

  tags {
    Name = "Paystack-igw"
  }
}

#subnet/az
resource "aws_subnet" "public" {
  availability_zone       = "${element(var.azs,count.index)}"
  cidr_block              = "10.0.${count.index}.0/24"
  count                   = "${length(var.azs)}"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.public.id}"
}

data "aws_subnet_ids" "public" {
  depends_on = ["aws_subnet.public"]
  vpc_id     = "${aws_vpc.public.id}"
}

#rtb for vpc and subnets
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.public.id}"

  tags {
    Name = "Paystack-rtb"
  }
}

# associate route table with each subnet
resource "aws_route_table_association" "public" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(data.aws_subnet_ids.public.ids, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
