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

    # Install K3s
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
    k3s kubectl create namespace twistlock
    
    # Install Defender
    sudo yum install jq -y
    AUTH_DATA="$(printf '{ "username": "%s", "password": "%s" }' "${var.pcc_username}" "${var.pcc_password}")"
    TOKEN=$(curl -sSLk -d "$AUTH_DATA" -H 'content-type: application/json' "https://${var.pcc_domain_name}/api/v1/authenticate" | jq -r ' .token ')
    curl -sSLk -H "authorization: Bearer $TOKEN" -X POST -d '{"orchestration": "Kubernetes", "consoleAddr": "${var.pcc_domain_name}", "namespace": "twistlock", "cri": true}' "https://${var.pcc_domain_name}/api/v22.06/defenders/daemonset.yaml" > daemonset.yaml
    k3s kubectl apply -f daemonset.yaml -n twistlock
    EOF

  tags = {
    Name     = "k3s-server"
    git_org  = "amckenzie7"
    git_repo = "Workload-Protection-on-ARM"
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
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_host]
  }
  ingress {
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
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
    Name     = "allow-ssh-web"
    git_org  = "amckenzie7"
    git_repo = "Workload-Protection-on-ARM"
  }
}
