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
provider "openstack" {
  insecure    = "true"
  user_name   = "admin"
  tenant_name = "admin"
  password    = "q9wsU2fwnP1vJBhpPEH7NfQlRC2Wr9k0"
  auth_url    = "https://192.168.50.133:5000/v3/" 
  region      = "microstack"
}
 #creer une cle ssh
resource "openstack_compute_keypair_v2" "keypair" {
  name = "key-web1"
}

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = "secgroup_web1"
  description = "My nginx web secu group"
}

resource "openstack_compute_instance_v2" "nginx_instance" {
  name            = "web-nginx"
  image_id        = "ff96930b-5b9e-4ef4-aeb8-3cc65c969792" # Replace with the ID of the image you want to use (e.g., Ubuntu, CentOS, etc.)
  flavor_id       = "3" # Replace with the ID of the flavor you want to use (e.g., m1.small, m1.medium, etc.)
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = ["secgroup_web1"]
}

resource "openstack_networking_secgroup_rule_v2" "allow_http" {
  direction      = "ingress"
  ethertype      = "IPv4"
  protocol       = "tcp"
  port_range_min = 80
  port_range_max = 80
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

resource "openstack_compute_floatingip_v2" "floating_ip" {
  pool = "external" # Replace with the name of the floating IP pool in your OpenStack setup
}

resource "openstack_compute_floatingip_associate_v2" "attach_floating_ip" {
  floating_ip = openstack_compute_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.nginx_instance.id
}

# Remote-exec provisioner to install Nginx and replace the default page with a custom page
resource "null_resource" "configure_nginx" {
  connection {
    host        = openstack_compute_floatingip_v2.floating_ip.address
    type        = "ssh"
    user        = "ubuntu" # Replace with the SSH user for your image (e.g., ubuntu, centos, etc.)
    private_key = file("~/.ssh/id_rsa") # Replace with the path to your SSH private key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "echo '<h1>Welcome to My Nginx Server!</h1>' | sudo tee /var/www/html/index.html",
      "sudo systemctl restart nginx"
    ]
  }
}
