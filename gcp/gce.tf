resource "google_compute_instance" "arm_instance" {
  name         = "arm-instance"
  machine_type = "t2a-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts-arm64"
      size  = 32
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = <<SCRIPT
    #!/bin/bash

    # Prepare the environment
    sudo apt update -y  

    # Install K3s
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
    k3s kubectl create namespace twistlock
        
    # Install Defender
    sudo apt install jq -y
    AUTH_DATA="$(printf '{ "username": "%s", "password": "%s" }' "${var.pcc_username}" "${var.pcc_password}")"
    TOKEN=$(curl -sSLk -d "$AUTH_DATA" -H 'content-type: application/json' "https://${var.pcc_domain_name}/api/v1/authenticate" | jq -r ' .token ')
    curl -sSLk -H "authorization: Bearer $TOKEN" -X POST -d '{"orchestration": "Kubernetes", "consoleAddr": "${var.pcc_domain_name}", "namespace": "twistlock", "cri": true}' "https://${var.pcc_domain_name}/api/v22.06/defenders/daemonset.yaml" > daemonset.yaml
    k3s kubectl apply -f daemonset.yaml -n twistlock
  SCRIPT
}
