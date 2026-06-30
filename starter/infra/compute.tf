resource "google_compute_instance" "k3s_node" {
  name         = "llmops-k3s-node"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["llmops-node"]

  scheduling {
    preemptible       = false
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = google_compute_network.llmops_vpc.name
    subnetwork = google_compute_subnetwork.llmops_subnet.name

    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  labels = {
    project = "baseline-llmops"
    phase   = "phase-3"
  }
}
