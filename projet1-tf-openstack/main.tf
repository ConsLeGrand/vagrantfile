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

# Creer l'instance nomme tf-srv1 
resource "openstack_compute_instance_v2" "instance_terraform" {
  name            = "tf-srv1"
  image_id        = "a03ee396-d3e8-46da-82ec-7222a5770544"   # id de notre image cirros
  flavor_id       = "1"                                      # l'id de notre gabarite m1.small
  key_pair        = "microstack"                             # nom de la cle ssh a utiliser pour se connecter a l'instance
  security_groups = ["default"]                              # nom du group de securite 

  metadata = {
    this = "that"
  }

# le reseau a utiliser 
  network {
    name = "external" # nom du resau 
  }
}
