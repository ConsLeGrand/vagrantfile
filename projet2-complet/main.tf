# Definir notre provider (openstack)
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}   

#Les infos  d'Auth
provider "openstack" {
  insecure    = "true"                             #Pour eviter le probleme d'auth due aux certificats auto-signe
  user_name   = "admin"                            #le nom de l'utilisateur
  tenant_name = "admin"                            #le nom du projet 
  password    = "q9wsU2fwnP1vJBhpPEH7NfQlRC2Wr9k0" # mot de passe de l'utilisateur
  auth_url    = "https://192.168.50.133:5000/v3/"  # URL Keystone, qui gere les authentification et les jetons de sec 
  region      = "microstack"                       # le nom de la region 
}

#creer un gabarite ou flavor en Anglais
resource "openstack_compute_flavor_v2" "test-flavor" {
  name  = "gabarite-1"
  ram   = "8096"
  vcpus = "5"
  disk  = "30"

  extra_specs = {
    "hw:cpu_policy"        = "CPU-POLICY",
    "hw:cpu_thread_policy" = "CPU-THREAD-POLICY"
  }
}

#creer une cle ssh
resource "openstack_compute_keypair_v2" "test-keypair" {
  name = "ma-cle"
}

#creer un group de sec
resource "openstack_compute_secgroup_v2" "my_secgroup" {
  name        = "my_secgroup"
  description = "my security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

#creer un reseau
resource "openstack_networking_network_v2" "mon_rx1" {
  name           = "mon_rx1"
  admin_state_up = "true"
}

#creer un sous reseaux
resource "openstack_networking_subnet_v2" "sous_rx1" {
  name       = "sous_rx1"
  network_id = openstack_networking_network_v2.mon_rx1.id
  cidr       = "192.168.30.0/24"
  ip_version = 4
}

#creer un routeur 
resource "openstack_networking_router_v2" "mon_rt1" {
  name           = "mon_rt1"
  admin_state_up = "true"
}

#creer une interface 
resource "openstack_networking_router_interface_v2" "int_1" {
  router_id = openstack_networking_router_v2.mon_rt1.id
  subnet_id = openstack_networking_subnet_v2.sous_rx1.id
}

#routage
resource "openstack_networking_router_route_v2" "router_route_1" {
  depends_on       = ["openstack_networking_router_interface_v2.int_1"]
  router_id        = openstack_networking_router_v2.mon_rt1.id
  destination_cidr = "10.20.20.0/24"
  next_hop         = "192.168.30.254"
}
 # Creer l'instance nomme tf-srv2 
resource "openstack_compute_instance_v2" "instance_terraform" {
  name            = "tf-srv2"
  image_id        = "ff96930b-5b9e-4ef4-aeb8-3cc65c969792"                 # id de notre image ubuntu14
  flavor_id       = openstack_compute_flavor_v2.test-flavor.id             # l'id de notre gabarite m1.small
  key_pair        = openstack_compute_keypair_v2.test-keypair.name         # nom de la cle ssh a utiliser pour se connecter a l'instance
  security_group_ids = [openstack_compute_secgroup_v2.my_secgroup.id]      # nom du group de securite 

  metadata = {
    this = "that"
  }

# le reseau a utiliser 
  network {
    name = "external" # nom du resau 
    #name = openstack_networking_network_v2.mon_rx1.name
  }
}