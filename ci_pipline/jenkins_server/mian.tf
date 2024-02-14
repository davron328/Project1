# Create Security Group
resource "aws_security_group" "jenkins_rules" {
  name        = "Jenkins rules"
  description = "Allow inbound traffic"
  
dynamic "ingress" {
    for_each = local.ingress
    content {
    description      = ingress.value.description
    from_port        = ingress.value.port
    to_port          = ingress.value.port
    protocol         = ingress.value.protocol
    cidr_blocks      = ["0.0.0.0/0"]
    }
}

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# resource "aws_key_pair" "deployer" {
#   key_name   = "kube-demo"
#   # public_key = file("public-key.pub")
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC53iqqYlnn0Yr/EeBX6mYBAiv0AWUfh8zZWqxUkFAl9vsqktERmEod150PcWy+SOGOvgRdvzTvD94En2cvkv4DTeRZSbt5jPvgJG764e6+1QWjO4GghDNIF2bfMTa0FjpoX35Wkcg/7Z3sRjL5uG4IHHkwWKasNszCriqw7XIuY4wkl0MD2ytin/SvNfft/TbgjLzxisd9gkQLxHzGLq5woPIIsEjxGPhYLnWyvFIy8c2R3XyF4Km/QvSRIjYA1ztP8M+DTBZbRIspqUJqqNDlGJpgyHD9iia/3waBN/zNvtsBALMrmtfb+JFLp52fsXzm2gZtO3d9xMZEcUurMUQMk5YNQ/riomz2scAdbKnX1Sj3V8XBWzU4jQMmHAclFE5PK+9qQKV3UAgjaRxy/tenylNKj2Expni03kYz+igrmAGDK4aZlpproXl/rKAaNM6B4PfQ+zhz01nC/Ih0Nl5ZQe4tNcAbldQt67nSTwJVLRyDm+z665hm7XN53G6mBzk= davronbeknormuradov@Davronbeks-MacBook-Pro.local"
# }
# Create EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins_rules.id]
  user_data = file("tools-install.sh")
  user_data_replace_on_change = true
  key_name = "kube-demo"

  tags = {
    Name = "Jenkins Server"
  }
  lifecycle {
    replace_triggered_by = [ aws_security_group.jenkins_rules.id ]
  }
}


# Define output
output "public_ip" {
  value = aws_instance.jenkins_server.public_ip
}