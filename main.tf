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

resource "google_compute_address" "k8s_cluster" {
  name = "${var.external_ip_name}"
}

resource "google_compute_instance" "master_nodes" {
  count                     = "${var.master_nodes_count}"
  name                      = "controller-${count.index}"
  machine_type              = "n1-standard-1"
  can_ip_forward            = true
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size  = 200
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.k8s_subnet.name}"
    network_ip    = "${cidrhost(var.subnet_cdir, count.index+10)}"
    access_config = {}
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  tags = ["kubernetes-the-hard-way", "controller"]
}

resource "google_compute_instance" "worker_nodes" {
  count                     = "${var.worker_nodes_count}"
  name                      = "worker-${count.index}"
  machine_type              = "n1-standard-1"
  can_ip_forward            = true
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size  = 200
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.k8s_subnet.name}"
    network_ip    = "${cidrhost(var.subnet_cdir, count.index+20)}"
    access_config = {}
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    pod-cidr = "${cidrsubnet(var.pods_cdir, 8, count.index)}"
  }

  tags = ["kubernetes-the-hard-way", "worker"]
}
