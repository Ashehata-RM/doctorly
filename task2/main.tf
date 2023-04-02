resource "aws_instance" "bastion" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  key_name          = "blog-admin"
  security_groups   = [ aws_security_group.allow_tls_http_ssh.id ]
  subnet_id         = var.subnet_id

  tags = {
    Name = "bastion-blog-ec2"
    Terraform = "true"
    Environment = "test"
    Project = "Learning Terraform"
  }
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    tags = {
      Name = "ebs-blog-bastion"
      Environment = "test"
      Terraform = "true"
      Project = "Learning Terraform"
    }
  }

  connection {
    type = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    host = "${self.public_ip}"
  }

  provisioner "file" {
    source      = "../task1/"
    destination = "/home/doctorly/"
  }

provisioner "file" {
    source      = "./ansible.sh"
    destination = "/home/doctorly/ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/doctorly/ansible.sh",
      "/home/doctorly/ansible.sh",
    ]
  }
}