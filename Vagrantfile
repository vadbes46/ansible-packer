# require 'yaml'
# require 'json'

# install plugins
need_restart = false
required_plugins = %w(vagrant-vbguest nugrant vagrant-cachier vagrant-hostmanager vagrant-disksize vagrant-bindfs)
required_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    need_restart = true
  end
end
exec "vagrant #{ARGV.join" "}" if need_restart

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
    v.gui = false
    v.memory = config.user.env.memory
    v.cpus = config.user.env.cpus
    v.customize ["modifyvm", :id, "--vram", 128]
    v.customize ["modifyvm", :id, "--acpi", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
    v.customize ["modifyvm", :id, "--vrde", "off"]
    v.customize ["modifyvm", :id, "--audio", "none"]
    v.customize ["modifyvm", :id, "--paravirtprovider", "kvm"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    # v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"] # symbolic links
  end

  config.vm.define "centos" do |node|
    node.vm.hostname = "ansible-centos"
    node.vm.network "private_network", nic_type: "virtio", ip: "#{config.user.env.ip}"
    # node.vm.network "private_network", nic_type: "virtio", type: "dhcp"

    # register shared folders
    node.vm.synced_folder "./", "/vagrant", disabled: true # disable default mapping    
    node.vm.synced_folder "./", "#{config.user.path.root_dir}/ansible-centos", create: true
    # node.vm.synced_folder ".", "/home/bitrix/www", owner: "bitrix", group: "bitrix", type: "smb", mount_options: ["mfsymlinks,dir_mode=0755,file_mode=0755"]
    if config.user.path.include? "sync_folder"
      config.user.path["sync_folder"].each do |sync_folder|
        if File.exists? File.expand_path(sync_folder["path"])

          sync_type = nil
          owner = nil
          group = nil
          mount_options = nil
          options = nil

          if sync_folder.include? "type"
            if (sync_folder["type"] == "nfs")
              mount_options = sync_folder["mount"] ? sync_folder["mount"] : ['actimeo=1', 'nolock']
              sync_type = "nfs"
            elsif (sync_folder["type"] == "smb")
              mount_options = sync_folder["mount"] ? sync_folder["mount"] : ['vers=3.02', 'mfsymlinks']
              sync_type = "smb"
            end
          end

          sync_type = sync_type ? sync_type : "virtualbox"
          owner = (sync_folder.has_key?("owner") && sync_folder["owner"]) ? sync_folder["owner"] : "vagrant"
          group = (sync_folder.has_key?("group") && sync_folder["group"]) ? sync_folder["group"] : "vagrant"
          mount_options = mount_options ? mount_options : (sync_folder.has_key?("mount") && sync_folder["mount"] ? sync_folder["mount"] : [])

          # check if user `www-data` exists
          # TODO

          # debug 1
          config.vm.provision "shell", run: "always", inline: <<-SHELL
            #!/usr/bin/env bash
            echo "#{sync_folder.path} #{sync_type} #{owner}:#{group} #{mount_options}"
            # echo #{options}
          SHELL

          # For b/w compatibility keep separate 'mount_options', but merge with options
          # options = (sync_folder["mount"] || {}).merge({ mount: mount_options })

          # # Double-splat (**) operator only works with symbol keys, so convert
          # options.keys.each{|k| options[k.to_sym] = options.delete(k) }


          # debug 2
          # node.vm.provision "shell", inline: <<-SHELL
          #   #!/usr/bin/env bash
          #   echo #{sync_folder.path.sub("../", '')}
          #   echo #{sync_folder.path.split('/')[0...-1].join('/')}
          #   echo #{sync_folder.path.split('/').last}
          # SHELL

          config.vm.synced_folder sync_folder["path"],
            "#{config.user.path.root_dir}/#{sync_folder.path.split('/').last}",
            type: sync_type,
            owner: owner,
            group: group,
            mount_options: mount_options
            # **options

    #         # Bindfs support to fix shared folder (NFS) permission issue on Mac
    #         if (folder["type"] == "nfs")
    #             if Vagrant.has_plugin?("vagrant-bindfs")
    #                 config.bindfs.bind_folder folder["to"], folder["to"]
    #             end
    #         end

        else
          config.vm.provision "shell" do |s|
            s.inline = ">&2 echo \"Unable to mount #{sync_folder.path}\""
          end
        end
      end
    end

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
      wget --no-check-certificate "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub" -O /home/vagrant/.ssh/authorized_keys 2>/dev/null
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
