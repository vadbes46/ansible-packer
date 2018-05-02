# install plugins
need_restart = false
required_plugins = %w(vagrant-vbguest nugrant vagrant-cachier vagrant-hostmanager vagrant-disksize vagrant-bindfs)
required_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    need_restart = true
  end
end
exec "vagrant #{ARGV.join' '}" if need_restart

# configure VM
Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.ssh.private_key_path = ["~/.vagrant.d/insecure_private_key"]
  # config.ssh.username = "vagrant"
  # config.ssh.password = "vagrant"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false

  # config.vm.box = "rarek/centos7"
  config.vm.box = "centos/7"
  # config.vm.box_version = "1.1.7"
  config.vm.box_check_update = true
  config.vbguest.auto_reboot = true
  # config.vbguest.yes = false

  config.vm.provider "virtualbox" do |v|
    v.memory = config.user.env.memory
    v.cpus = config.user.env.cpus
    v.customize ['modifyvm', :id, '--vram', 128]
    v.customize ['modifyvm', :id, '--acpi', 'on']
    v.customize ['modifyvm', :id, '--ioapic', 'on']
    v.customize ['modifyvm', :id, '--vrde', 'off']
    v.customize ['modifyvm', :id, '--audio', 'none']
    v.customize ['modifyvm', :id, '--paravirtprovider', 'kvm']
    v.customize ["modifyvm", :id, '--natdnsproxy1', 'on']
    v.customize ["modifyvm", :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--nictype1', 'virtio']
  end

  config.vm.define 'centos' do |node|
    node.vm.hostname = 'ansible-centos'
    node.vm.network "private_network", nic_type: 'virtio', ip: "#{config.user.env.ip}"
    # node.vm.network "private_network", nic_type: 'virtio', type: "dhcp"

    node.vm.synced_folder "./", "/vagrant", disabled: true # disable default mapping
    node.vm.synced_folder "./", "#{config.user.path.root_dir}/ansible-centos", create: true
    node.vm.synced_folder config.user.path.plus, "#{config.user.path.root_dir}/plus", create: true, mount_options: ["dmode=777,fmode=777"]
    node.vm.synced_folder config.user.path.logs, "#{config.user.path.root_dir}/logs", create: true, owner: "vagrant", group: "vagrant", mount_options: ["dmode=777,fmode=777"] # sync guest logs to the host

    node.hostmanager.aliases = [
      "#{config.user.host.host_plus}",
      "#{config.user.host.host_gate}",
      "#{config.user.host.host_mock}",
      ]

    node.vm.provision "file", source: config.user.id_rsa.deployer_id_rsa, destination: "/home/vagrant/.ssh/id_rsa"
    node.vm.provision "file", source: config.user.id_rsa.deployer_id_rsa_pub, destination: "/home/vagrant/.ssh/id_rsa.pub"
    node.vm.provision "shell", inline: <<-SHELL
      #!/usr/bin/env bash
      if [ ! -d /etc/ansible/facts.d ]; then
        yum install epel-release ansible wget -y &>/dev/null
        yum repolist &>/dev/null
        yum update -y &>/dev/null
      fi
      wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys 2>/dev/null
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/id_rsa
      chmod 644 /home/vagrant/.ssh/id_rsa.pub
      cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
      ssh-keyscan -p 7999 -H stash.paymantix.com 78.140.183.181 > /home/vagrant/.ssh/known_hosts 2>/dev/null
      chown -R vagrant:vagrant /home/vagrant/.ssh
      if [ ! -e /vagrant ]; then
        ln -s /data/ansible-centos /vagrant;
      fi
      sudo sed -i "s/.*host_key_checking.*/host_key_checking = False/g" /etc/ansible/ansible.cfg
    SHELL

    if config.user.env.in_office then
      limit = "office"
      tags = "vagrant_office"
    else
      limit = "dev"
      tags = "vagrant_dev"
    end

    provisioner = :ansible_local
    node.vm.provision provisioner do |ansible|
      ansible.inventory_path = "/data/ansible-centos/provision/hosts"
      ansible.playbook = "/data/ansible-centos/provision/site.yml"
      ansible.limit = limit
      ansible.compatibility_mode = "2.0"
      ansible.tags = tags
      #ansible.verbose = "vvv"
    end

    if config.user.env.in_office then
      node.vm.provision "shell", run: "always", inline: <<-SHELL
        #!/usr/bin/env bash
        bash /etc/rc.local
      SHELL
    end
  end
end
