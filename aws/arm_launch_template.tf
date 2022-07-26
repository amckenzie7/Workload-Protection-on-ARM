resource "aws_launch_template" "arm_template" {
  name          = "graviton_template"
  image_id      = var.ami_image_id
  instance_type = var.instance_type
  key_name      = var.key_pair

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 32
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_options {
    core_count       = 2
    threads_per_core = 1
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "arm-instance"
    }
  }
}