Vagrant.configure("2") do |config|
  config.vm.box = "debian12-utm"

  config.vm.provider :utm do |utm|
    utm.memory = 2048
    utm.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install -y docker.io docker-compose git python3-pip
    systemctl enable docker
    usermod -aG docker vagrant || true
    pip3 install ansible
  SHELL
end
