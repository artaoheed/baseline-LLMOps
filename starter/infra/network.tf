resource "google_compute_network" "llmops_vpc" {
  name                    = "llmops-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "llmops_subnet" {
  name          = "llmops-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.llmops_vpc.id
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "llmops-allow-ssh"
  network = google_compute_network.llmops_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["llmops-node"]
}

resource "google_compute_firewall" "allow_web" {
  name    = "llmops-allow-web"
  network = google_compute_network.llmops_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["llmops-node"]
}

resource "google_compute_firewall" "allow_k3s" {
  name    = "llmops-allow-k3s"
  network = google_compute_network.llmops_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["llmops-node"]
}
