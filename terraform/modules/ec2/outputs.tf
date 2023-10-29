output "observe_private_ip" {
  value = aws_network_interface.observe_private_eni.private_ip
}
output "flask_private_ips" {
  value = aws_network_interface.flask_private_eni.*.private_ip
}

output "observe_instance_id" {
  value = aws_instance.observe_master.id
}
output "flask_instance_ids" {
  value = aws_instance.flask_instances.*.id
}
