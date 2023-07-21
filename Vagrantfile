Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
  
  config.vm.define "k8s-master" do |k8m|
    k8m.vm.hostname = "k8s-master"
    k8m.vm.network "private_network", ip: "192.168.33.40"
  end
  
  config.vm.define "k8s-node-1" do |k8sn1|
    k8sn1.vm.hostname = "k8s-node-1"
    k8sn1.vm.network "private_network", ip: "192.168.33.41"
  end
  
  config.vm.define "k8s-node-2" do |k8sn2|
    k8sn2.vm.hostname = "k8s-node-2"
    k8sn2.vm.network "private_network", ip: "192.168.33.42"
  end

  config.vm.define "deploy" do |deploy|
    deploy.vm.hostname = "deploy"
    deploy.vm.network "private_network", ip: "192.168.33.43"
  end
end
