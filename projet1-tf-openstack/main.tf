# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  insecure    = "true"
  user_name   = "admin"
  tenant_name = "admin"
  password    = "q9wsU2fwnP1vJBhpPEH7NfQlRC2Wr9k0"
  auth_url    = "https://192.168.50.133:5000/v3/" 
  region      = "microstack"
}

# Create a web server
resource "openstack_compute_instance_v2" "instance_terraform" {
  name            = "tf-srv1"
  image_id        = "a03ee396-d3e8-46da-82ec-7222a5770544"
  flavor_id       = "1"
  key_pair        = "microstack"
  security_groups = ["default"]

  metadata = {
    this = "that"
  }

  network {
    name = "external"
  }
}
