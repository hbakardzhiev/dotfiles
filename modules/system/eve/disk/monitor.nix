{ config, pkgs, ... }:

{
  # Enable smartmontools for disk monitoring
  services.smartd = {
    enable = true;
    # Monitor both disks, notify on errors
    devices = [
      {
        device = "/dev/sdb"; # First disk
        options = "-d sat,auto -a -H -l error -l selftest -m your-email@gmail.com -M exec ${pkgs.msmtp}/bin/msmtp";
      }
      {
        device = "/dev/sdc"; # Second disk
        options = "-d sat,auto -a -H -l error -l selftest -m your-email@gmail.com -M exec ${pkgs.msmtp}/bin/msmtp";
      }
    ];
    notifications = {
      mail = {
        enable = true;
        sender = "h.bakardzhiev@gmx.com";
        recipient = "h.bakardzhiev@gmx.com";
      };
    };
  };

  # Configure msmtp for sending emails
  programs.msmtp = {
    enable = true;
    setSendmail = true; # Use msmtp as the default sendmail
    accounts = {
      default = {
        host = "smtp.gmx.com";
        port = 587;
        from = "h.bakardzhiev@gmx.com";
        user = "h.bakardzhiev@gmx.com";
        passwordeval = "cat ${config.sops.secrets.gmx.path}";
        tls = true;
        tls_starttls = true;
      };
    };
  };

  # Optional: Open firewall ports for SMTP (if needed)
  networking.firewall.allowedTCPPorts = [ 587 ];
}
