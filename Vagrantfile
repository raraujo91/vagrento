# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|

#  Uncomment this line below if you are running Hyper-V instead VM or 
#  VirtualBox. If you are running with one of those, leave commented. 

#  config.vm.provider "hyperv"

  config.vm.box = "ubuntu/precise32"

#  If you are a Hyper-V user please select a compatible box such as 
#  "hashicorp/precise64" (recommended) or "laravel/homestead". 

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder ".", "/var/www", nfs: true
#  config.vm.synced_folder ".", "/var/www", smb: true

  config.ssh.forward_agent = true

  config.vm.provision :shell, :path => "bootstrap.sh"

end
