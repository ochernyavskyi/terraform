provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

resource "aws_instance" "my_websrver" {
  ami = "ami-093b8289535bbca9a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.MyWebServer.id]
  tags = {
    Name = "MyWebServer"
  }
  user_data = <<-EOF
#!/bin/bash
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "Internal ip of server is: $myip" > index.html
nohup busybox httpd -f -p 8080 &
EOF
}

resource "aws_security_group" "MyWebServer" {
  name = "WebServer Security Group"

  #Income traffic
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"] #Ip address
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  #Outcome traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "MyWebServerSecurityGroup"
  }
}

output "public_ip" {
  value = aws_instance.my_websrver.public_ip
  description = "The public IP address of the web server"
}