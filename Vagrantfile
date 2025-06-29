Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_version = "202502.21.0"
  config.vm.box_check_update = false

  config.vm.provider "parallels" do |v|
    v.memory = 8192
    v.cpus = 8
    v.name = "directus-dev-#{Time.now.to_i}"
  end

  config.vm.synced_folder ".", "/vagrant",
    type: "nfs",
    nfs_version: 3,
    mount_options: ['rw', 'tcp', 'noatime', 'actimeo=2']

  config.vm.network "forwarded_port", guest: 8055, host: 8055, auto_correct: true
  config.vm.network "forwarded_port", guest: 3000, host: 3000, auto_correct: true

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      sudo

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    usermod -aG docker vagrant
    systemctl enable docker
    systemctl start docker
  SHELL
end
