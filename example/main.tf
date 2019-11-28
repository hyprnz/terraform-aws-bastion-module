resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "Example VPC"
  }
}

resource "aws_subnet" "example_subnet" {
  cidr_block = "10.0.0.0/26"
  vpc_id     = aws_vpc.example_vpc.id
}

module "example" {
  source              = "../"
  name                = "IamAmBastion"
  s3_bucket_namespace = "phiroict"
  vpc_id              = aws_vpc.example_vpc.id
  subnet_ids          = [aws_subnet.example_subnet.id]
  keys_to_prime       = ["id_rsa_phiroict_github.pub"]
}

