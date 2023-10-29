// Create the pem key which will allow ansible to connect via SSH 
// will maybe not work, so better to test it out before deployment
resource "tls_private_key" "ssh_key" {
    algorith              = "RSA"
    rsa_bits              = 4096
}

resource "aws_key_pair" "key_pair" {
    key_name              = "terra_gen_key" 
    public_key            = tls_private_key.ssh_key.public_key_openssh
}

resource "local_sensitive_file" "pem_file" {
  filename                = pathexpand("~/.ssh/${aws_key_pair.key_pair.key_name}.pem")
  file_permission         = "600"
  directory_permission    = "700"
  content = tls_private_key.ssh_key.private_key_pem
}

resource "aws_network_interface" "public_eni" {
    subnet_id             = var.main_private_subnet.id

    tags = {
        Name = "public-eni-01"
    }
}

resource "aws_network_interface" "private_eni" {
    count                 = 2
    subnet_id             = var.main_private_subnet.id

    tags = {
        Name = format("private-eni-0%d", count.index)
    }
}

resource "aws_instance" "flask_instances" {
  ami                  = var.base_ami
  instance_type        = var.instance_type
  count                = var.flask_instances_count
  key_name             = aws_key_pair.key_pair.key_name
  iam_instance_profile = var.ec2_profile_name
  
  root_block_device {
  │ delete_on_termination = true
  │ volume_size           = 5
  │ volume_type           = "gp2"
  }
  
  network_interface {
  │ network_interface_id = element(aws_network_interface.geth_private, count.index).id
  │ device_index         = 0
  }
  
  tags = {
  │ Name     = format("geth-%03d.%s", count.index + 1, var.base_dn)
  │ Hostname = format("geth-%03d", count.index + 1)
  │ Role     = "geth"
  }
}
