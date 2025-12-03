resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = file("~/.ssh/bastion.pub")
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "SSH solo desde IP local"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["190.187.184.90/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.ec2_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1.id
  key_name                    = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}
