$script = <<SCRIPT
#!/bin/bash

set -eu

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y autoconf2.13 automake build-essential bsdmainutils faketime g++ g++-mingw-w64 git-core libqt4-dev libtool libz-dev mingw-w64 nsis pciutils pkg-config psmisc subversion unzip zip

echo "ok"

SCRIPT

archs = ["amd64", "i386"]
suites = ["precise", "quantal", "raring", "saucy", "trusty"]

if ARGV[0] == "up" and ARGV.length == 1
  puts "Specify a name of the form 'suite-architecture'"
  puts "  suites: " + suites.join(', ')
  puts "  architectures: " + archs.join(', ')
  Process.exit 1
end

Vagrant.configure("2") do |config|

  config.vm.provision "shell", inline: $script
  config.vm.network :forwarded_port, id: "ssh", guest: 22, host: 2223

  suites.each do |suite|
    archs.each do |arch|
      name = "#{suite}-#{arch}"

      config.vm.define name do |config|
        config.vm.box = name
        config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/#{suite}/current/#{suite}-server-cloudimg-#{arch}-vagrant-disk1.box"
        config.vm.provider :virtualbox do |vb|
          vb.name = "Gitian-#{name}"
        end
      end
    end
  end

  config.vm.provider :virtualbox do |vb|
    vb.memory = 4096
  end
end
