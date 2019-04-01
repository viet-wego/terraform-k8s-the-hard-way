resource "google_compute_network" "vpc_network" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k8s_subnet" {
  name          = "${var.subnet_name}"
  ip_cidr_range = "${var.subnet_cdir}"
  region        = "${var.gcp_region}"
  network       = "${google_compute_network.vpc_network.name}"
}

resource "google_compute_firewall" "k8s_internal" {
  name    = "${var.firewall_k8s_internal_name}"
  network = "${google_compute_network.vpc_network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = ["${var.subnet_cdir}", "${var.pods_cdir}"]
}

resource "google_compute_firewall" "k8s_external" {
  name    = "${var.firewall_k8s_external_name}"
  network = "${google_compute_network.vpc_network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  source_ranges = ["${var.subnet_cdir}", "${var.pods_cdir}"]
}
