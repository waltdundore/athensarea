# Vagrantfile for AthensArea infrastructure dev
# ✅ Optimized for macOS ARM (M1/M2/M3) with Parallels

Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian12"
  config.vm.box_version = "4.3.2"  # Stable release with ARM64 support

  config.vm.provider "parallels" do |p|
    p.memory = 2048
    p.cpus = 2
  end

  config.vm.network "private_network", type: "dhcp"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update -y
    apt-get install -y docker.io docker-compose git python3-pip
    pip3 install ansible
    usermod -aG docker vagrant || true
    systemctl enable docker
  SHELL
end
