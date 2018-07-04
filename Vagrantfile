Vagrant.require_version '>= 2.1.0'

# require 'yaml'
# require 'json'

# install plugins
need_restart = false
required_plugins = %w(vagrant-vbguest nugrant vagrant-hostmanager)
# required_plugins = %w(vagrant-vbguest nugrant vagrant-cachier vagrant-hostmanager vagrant-disksize vagrant-bindfs)
required_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    need_restart = true
  end
end
exec "vagrant #{ARGV.join" "}" if need_restart

# check .vagrantuser
vagrantUserDir = File.expand_path(File.dirname(__FILE__))
if File.exist? vagrantUserDir + "/.vagrantuser" then
  vagrantuserDate = File.mtime(vagrantUserDir + "/.vagrantuser")
  vagrantuserExampleDate = File.mtime(vagrantUserDir + "/.vagrantuser.example")
  if (vagrantuserDate.to_i < vagrantuserExampleDate.to_i)
    puts "\t" + "\e[41m.vagrantuser\e[0m" + " file is " + "\e[41mOUTDATED\e[0m" + "\n\t" + "---> please recreate <---"
    exit 0
  end
else
  puts "\t" + "\e[41m.vagrantuser\e[0m" + " file " + "\e[41mNOT FOUND\e[0m" + " in:" + "\n\t" + "#{vagrantUserDir}"
  exit 0
end

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

  config.vm.box = "vadbes46/centos-box"
  # config.vm.box = "boxcentos"
  config.vm.box_version = "1.0.0"
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
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    # v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    # v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"] # symbolic links
  end

  config.vm.define "centos" do |node|
    node.vm.hostname = "dev"
    node.vm.network "private_network", nic_type: "virtio", ip: "#{config.user.env.ip}"

    # register shared folders
    node.vm.synced_folder "./", "/vagrant", disabled: true # disable default mapping
    node.vm.synced_folder "./", "#{config.user.path.root_dir}/ansible", create: true
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

          # check that host is available to reduce time
          # remove previous entry in known_hosts
          # check if user `www-data` exists
          # mount as `vagrant` if any problems
          system "ret=$(ssh-keygen -f ~/.ssh/known_hosts -R \"#{config.user.env.ip}\") 2>/dev/null"
          system "ret=$(ssh-keyscan -t rsa -H \"#{config.user.env.ip}\" 2>/dev/null >> ~/.ssh/known_hosts)"
          hostExists = system "ret=$(ping -c 1 -W 1 -q \"#{config.user.env.ip}\")"
          if (hostExists)
          #   puts "\t host exists"
            wwwDataUser = system "ssh \"#{config.user.env_const.username}\"@\"#{config.user.env.ip}\" -i ~/.vagrant.d/insecure_private_key -t 'bash -ic \"id \"#{config.user.nginx_fpm.user_group}\";\" &>/dev/null' 2>/dev/null"
            if (wwwDataUser)
          #     puts "`www-data` exists"
            else
              owner = (owner == "www-data") ? "vagrant" : owner
              group = (group == "www-data") ? "vagrant" : group
          #     puts "`www-data` NOT exist"
            end
          else
            owner = (owner == "www-data") ? "vagrant" : owner
            group = (group == "www-data") ? "vagrant" : group
          #   puts "\t host DOES NOT exist"
          end

          # debug 1
          # config.vm.provision "shell", privileged: false, run: "always", inline: <<-SHELL
          #   #!/usr/bin/env bash
          #   echo "#{sync_folder.path} #{sync_type} #{owner}:#{group} #{mount_options}"
          #   # echo #{options}
          # SHELL

          # For b/w compatibility keep separate 'mount_options', but merge with options
          # options = (sync_folder["mount"] || {}).merge({ mount: mount_options })

          # # Double-splat (**) operator only works with symbol keys, so convert
          # options.keys.each{|k| options[k.to_sym] = options.delete(k) }

          # debug 2
          # node.vm.provision "shell", privileged: false, inline: <<-SHELL
          #   #!/usr/bin/env bash
          #   echo #{sync_folder.path.sub("../", '')}
          #   echo #{sync_folder.path.split('/')[0...-1].join('/')}
          #   echo #{sync_folder.path.split('/').last}
          # SHELL

          # debug 3
          # vagrantUser = vagrantUserDir + "/.vagrantuser"
          # node.vm.provision "shell", privileged: false, inline: <<-SHELL
          #   #!/usr/bin/env bash
          #   echo #{vagrantUser}
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
      "#{config.user.env.host_prefix}#{config.user.host.gate}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.worker}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.db}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.admin}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.nadmin}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.kafka01}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}api.#{config.user.host.terminal}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}dash.#{config.user.host.terminal}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}pp.#{config.user.host.terminal}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}admin.#{config.user.host.terminal}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}sdk.#{config.user.host.terminal}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.plus}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.mock}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.xhprof}#{config.user.env.host_postfix}",
      "#{config.user.env.host_prefix}#{config.user.host.tracer}#{config.user.env.host_postfix}",
    ]

    node.vm.provision "file", source: config.user.id_rsa.deployer_id_rsa, destination: "/home/vagrant/.ssh/id_rsa"
    node.vm.provision "file", source: config.user.id_rsa.deployer_id_rsa_pub, destination: "/home/vagrant/.ssh/id_rsa.pub"
    node.vm.provision "shell", privileged: true, inline: <<-SHELL
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
      ssh-keyscan -H -p 7999 -t rsa stash.paymantix.com > /home/vagrant/.ssh/known_hosts 2>/dev/null
      sed -i "s/^\\[.*ssh-rsa/\\[stash.paymantix.com\\]:7999,\\[206.54.161.160\\]:7999,\\[206.54.161.161\\]:7999 ssh-rsa/g" /home/vagrant/.ssh/known_hosts
      # ssh-keyscan -H -p 7999 -t rsa stash.ecommpay.com > /home/vagrant/.ssh/known_hosts 2>/dev/null
      # sed -i "s/^\\[.*ssh-rsa/\\[stash.ecommpay.com\\]:7999,\\[206.54.161.160\\]:7999,\\[206.54.161.161\\]:7999 ssh-rsa/g" /home/vagrant/.ssh/known_hosts
      ssh-keyscan -H -t rsa github.com >> /home/vagrant/.ssh/known_hosts 2>/dev/null
      chown -R vagrant:vagrant /home/vagrant/.ssh
      if [ ! -e /vagrant ]; then
        ln -s #{config.user.path.root_dir}/ansible /vagrant;
      fi
      sed -i "s/.*host_key_checking.*/host_key_checking = False/g" /etc/ansible/ansible.cfg
      sed -i "s/.*command_warnings.*/command_warnings = False/g" /etc/ansible/ansible.cfg
    SHELL

    node.vm.provision "shell", inline: <<-SHELL
      #!/bin/bash
      echo #{config.user.env.vault_pass} > /home/vagrant/.vault_pass
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
      ansible.inventory_path = "#{config.user.path.root_dir}/ansible/provision/hosts"
      ansible.playbook = "#{config.user.path.root_dir}/ansible/provision/site.yml"
      ansible.limit = limit
      ansible.compatibility_mode = "2.0"
      ansible.tags = tags
      if config.user.env.vault_pass != "" then
        ansible.vault_password_file = "/home/vagrant/.vault_pass"
      end
      # ansible.verbose = "vvv"
      # ansible.raw_arguments = ["--connection=paramiko"]
    end

    if config.user.env.in_office then
      node.vm.provision "shell", privileged: false, run: "always", inline: <<-SHELL
        #!/usr/bin/env bash
        bash /etc/rc.local
      SHELL
    end
  end
end
