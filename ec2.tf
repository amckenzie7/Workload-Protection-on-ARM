resource "aws_instance" "web-server" {
  key_name                    = var.key_pair
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.subnet-tf.id
  vpc_security_group_ids      = [aws_security_group.allow-ssh-web.id]
  launch_template {
    id      = aws_launch_template.arm_template.id
    version = "$Latest"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -ex

    # Prepare the environment
    sudo yum update -y  

    # Install minikube 
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
    sudo install minikube-linux-arm64 /usr/local/bin/minikube

    # Install Docker
    sudo yum install docker -y
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    sudo usermod -aG docker ec2-user
    sudo newgrp docker
    
    # Start minikube 
    minikube start --force
    minikube kubectl -- create namespace twistlock

    # Install Defender
    sudo yum install jq -y
    AUTH_DATA="$(printf '{ "username": "%s", "password": "%s" }' "${var.pcc_username}" "${var.pcc_password}")"
    TOKEN=$(curl -sSLk -d "$AUTH_DATA" -H 'content-type: application/json' "https://${var.pcc_domain_name}/api/v1/authenticate" | jq -r ' .token ')
    # curl -sSLk -H "authorization: Bearer $TOKEN" -X POST "https://${var.pcc_domain_name}/api/v1/scripts/defender.sh" | sudo bash -s -- -c "${var.pcc_domain_name}" -d "none" -m
    # if [[ ! -f ./twistcli || $(./twistcli --version) != *"22.06.179"* ]]; then curl --progress-bar -L -k --header "authorization: Bearer $TOKEN https://${var.pcc_domain_name}/api/v1/util/arm64/twistcli > twistcli; chmod +x twistcli; fi; ./twistcli defender install kubernetes --namespace twistlock --monitor-service-accounts --token $TOKEN --address https://${var.pcc_domain_name} --cluster-address ${var.pcc_domain_name} 
    curl -sSLk -H "authorization: Bearer $TOKEN" -X POST -d '{"orchestration": "Kubernetes", "consoleAddr": "${var.pcc_domain_name}", "namespace": "twistlock"} "https://${var.pcc_domain_name}/api/v1/defenders/daemonset.yaml"
    minikube kubectl -- apply -f daemonset.yaml  
    EOF

  tags = {
    Name = "minikube-server"
  }
  monitoring = true
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_security_group" "allow-ssh-web" {
  name        = "allow-ssh-web"
  description = "Allow SSH and Web inbound traffic"
  vpc_id      = aws_vpc.vpc-tf.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from specific host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_host]
  }

  egress {
    description = "allow all outbound connections"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh-web"
  }
}
