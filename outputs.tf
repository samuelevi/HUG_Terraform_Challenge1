output "instance_public_ip" {
   description = "the public ip of the EC2 instance"
   value = aws_instance.web.public_ip
}

output "instance_public_dns" {
   description = "the public dns of the EC2 instance"
   value = aws_instance.web.public_dns
}