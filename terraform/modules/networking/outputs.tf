output "main_public_subnet" {
    value = aws_subnet.main_public.id
}
output "main_private_subnet" {
    value = aws_subnet.main_private.id
}
output "main_vpc" {
    value = aws_vpc.main.id
}