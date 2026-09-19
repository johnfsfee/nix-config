{ config, pkgs, lib, ... }:

{
  services = {
    i2pd = {
      enable = true;
      proto.httpProxy.enable = true;
    };

    zerotierone.enable = true;
  };

  ## Networking & Host Resolution ##
  networking = {
    extraHosts = ''
      127.0.0.1 localhost damnix
      ::1 localhost
    '';

    nameservers = [ "127.0.0.1" "::1" ];

    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.dns = "none";
    resolvconf.enable = true;
    resolvconf.useLocalResolver = true;
  };

  ## Encrypted DNS (dnscrypt-proxy) ##
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      # Listen on BOTH IPv4 and IPv6 loopback interfaces
      listen_addresses = [ "127.0.0.1:51" "[::1]:51" ];

      # Disable ipv6_servers if your local ISP/router lacks IPv6 WAN routing
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };

  systemd.services.dnscrypt-proxy.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  ## Services: Tor & Privoxy ##
  services.privoxy.enable = true;
  services.privoxy.enableTor = true;

  services.tor = {
    enable = true;
    client.enable = true;
  };

  ## Firewall & DNS Redirection ##
  networking.firewall = {
    enable = true;

    # Redirect BOTH IPv4 and IPv6 DNS traffic on port 53 to dnscrypt-proxy on port 51
    extraCommands = ''
      iptables -t nat -F OUTPUT 2>/dev/null || true
      ip6tables -t nat -F OUTPUT 2>/dev/null || true

      # IPv4 Redirects
      iptables -t nat -A OUTPUT -p udp --dport 53 -d 127.0.0.1 -j REDIRECT --to-ports 51
      iptables -t nat -A OUTPUT -p tcp --dport 53 -d 127.0.0.1 -j REDIRECT --to-ports 51

      # IPv6 Redirects
      ip6tables -t nat -A OUTPUT -p udp --dport 53 -d ::1 -j REDIRECT --to-ports 51
      ip6tables -t nat -A OUTPUT -p tcp --dport 53 -d ::1 -j REDIRECT --to-ports 51
    '';

    allowedTCPPorts = [ 45869 47984 47989 47990 48010 ];
    allowedTCPPortRanges = [ { from = 10666; to = 10670; } ];
    allowedUDPPortRanges = [
      { from = 10666; to = 10670; }
      { from = 47989; to = 48000; }
      { from = 8000; to = 8010; }
    ];
  };

  ## Samba Share Config ##
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "auto";
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "# server min protocol" = "NT1";
        "# lanman auth" = "yes";
        "# ntlm auth" = "yes";
        "hosts allow" = "192.168.122. 127. 192.168.0. 192.168.1. 127.0.0.1 localhost fe80::/10";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "path" = "/mnt/Shares/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0775";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/Shares/Public 0775 root users -"
  ];
}
