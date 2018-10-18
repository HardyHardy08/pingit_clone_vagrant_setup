# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "bootstrap.sh"
  # leave network setting in main config for now; move into vagrant specific configs later
  config.vm.network :forwarded_port, guest: 80, host: 5678

  config.vm.provider "virtualbox" do |v|
    v.name = "my_vm"
    # need to know how much CPU/memory is available before setting variables
    # v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    # v.cpus = 2
    # v.memory = 256
    end

  # config.vm.define ???
end