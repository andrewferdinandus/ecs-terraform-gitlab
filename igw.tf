#Main VPC of the ECS Setup
resource "aws_internet_gateway" "igw" {
  vpc_id = var.aws_vpc.main_vpc.id

  tags = {
    Name = "Gateway"
  }
}

locals {
  public_web_defs = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => { cidr = cidr, az = var.azs[idx] }
  }
}

# Public  Subnets
resource "aws_subnet" "public_web" {
  for_each                = local.public_web_defs
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true #just for ssh from public

  tags = {
    Name = "Public  Subnet ${tonumber(each.key) + 1}"
    
  }
}

#Public Route Table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "Public Route Table"
  }

}

#Associate Route Table with public subnets
resource "aws_route_table_association" "public_route" {
  for_each       = aws_subnet.public_web
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route.id
}
