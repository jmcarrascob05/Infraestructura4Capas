Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  # BALANCEADOR (conecta red externa con redwebsNFS)
  config.vm.define "balanceadorJuanma" do |balanceadorJuanma|
    balanceadorJuanma.vm.hostname = "balanceadorJuanma"
    balanceadorJuanma.vm.network "private_network", ip: "192.168.10.10", virtualbox__intnet: "redbalanceador"
    balanceadorJuanma.vm.network "private_network", ip: "192.168.20.5", virtualbox__intnet: "redwebsNFS"
    balanceadorJuanma.vm.network "forwarded_port", guest: 80, host: 8080
    balanceadorJuanma.vm.provision "shell", path: "aprov/balanceadorJuanma.sh"
  end

  # WEB1
  config.vm.define "web1Juanma" do |web1Juanma|
    web1Juanma.vm.hostname = "web1Juanma"
    web1Juanma.vm.network "private_network", ip: "192.168.20.10", virtualbox__intnet: "redwebsNFS"
    web1Juanma.vm.provision "shell", path: "aprov/web1Juanma.sh"
  end

  # WEB2
  config.vm.define "web2Juanma" do |web2Juanma|
    web2Juanma.vm.hostname = "web2Juanma"
    web2Juanma.vm.network "private_network", ip: "192.168.20.15", virtualbox__intnet: "redwebsNFS"
    web2Juanma.vm.provision "shell", path: "aprov/web2Juanma.sh"
  end
  # HAProxy (conecta redhaproxy con reddb)
  config.vm.define "haproxy" do |haproxy|
    haproxy.vm.hostname = "haproxy"
    haproxy.vm.network "private_network", ip: "192.168.30.10", virtualbox__intnet: "redhaproxy"
    haproxy.vm.network "private_network", ip: "192.168.40.5", virtualbox__intnet: "reddb"
    haproxy.vm.provision "shell", path: "aprov/haproxyJuanma.sh"
  end

  # DB1
  config.vm.define "db1Juanma" do |db1Juanma|
    db1Juanma.vm.hostname = "db1Juanma"
    db1Juanma.vm.network "private_network", ip: "192.168.40.10", virtualbox__intnet: "reddb"
    db1Juanma.vm.provision "shell", path: "aprov/db1Juanma.sh"
  end

  # DB2
  config.vm.define "db2Juanma" do |db2Juanma|
    db2Juanma.vm.hostname = "db2Juanma"
    db2Juanma.vm.network "private_network", ip: "192.168.40.11", virtualbox__intnet: "reddb"
    db2Juanma.vm.provision "shell", path: "aprov/db2Juanma.sh"
  end
  # NFS (conecta redwebsNFS con redhaproxy)
  config.vm.define "nfsJuanma" do |nfsJuanma|
    nfsJuanma.vm.hostname = "nfsJuanma"
    nfsJuanma.vm.network "private_network", ip: "192.168.20.20", virtualbox__intnet: "redwebsNFS"
    nfsJuanma.vm.network "private_network", ip: "192.168.30.20", virtualbox__intnet: "redhaproxy"
    nfsJuanma.vm.provision "shell", path: "aprov/NFSJuanma.sh"
  end
end