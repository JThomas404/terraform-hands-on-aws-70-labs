output "hello-world" {
  description = "Print Hello World text output"
  value       = "Hello World"
}

output "vpc_id" {
  description = "Output the ID for the primary VPC"
  value       = aws_vpc.tf_mastery_vpc.id
}

output "public_url" {
  description = "Public URL for the Web Server"
  value       = "https://${aws_instance.tf_mastery_ec2.private_ip}:8080/index.html"
}

output "vpc_information" {
  description = "VPC Information about Environment"
  value       = "The ${aws_vpc.tf_mastery_vpc.tags.Environment} VPC has an ID of ${aws_vpc.tf_mastery_vpc.id}"
}
