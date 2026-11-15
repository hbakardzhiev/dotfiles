{
  lib,
  pkgs,
  ...
}:

# Chromium on Linux reads client certificates and local trust settings from
# the per-user NSS database at ~/.pki/nssdb (not from ~/.config/chromium).
# B-Trust's Chrome instructions do two things by hand that we do here:
#
#   1. register the Gemalto/IDPrime PKCS#11 module with `modutil`,
#   2. import the B-Trust root and intermediate with `certutil`.
#
# The instructions also import the self-signed `BISS Root localhost` CA that
# B-Trust's local signing service uses.  That is deliberately not done: BISS
# is not installed here, and a trusted CA without name constraints would be
# allowed to vouch for any hostname.  Add it back only if BISS is installed.
#
# The PKCS#11 library is exposed through a stable symlink in the home
# directory.  NSS stores the library path in its own database, so pointing it
# straight at /nix/store would break after a nixpkgs update changes the hash.
let
  btrustRootQca = pkgs.fetchurl {
    url = "https://ca.b-trust.org/repository/B-TrustRootQCA.cer";
    hash = "sha256-SzXLKoJh3TT8fHIPRbvCE1zPP0ndZ5tvnkLnlUVeD8w=";
  };
  btrustOperationalQca = pkgs.fetchurl {
    url = "https://ca.b-trust.org/repository/B-TrustOperationalQCA.cer";
    hash = "sha256-djkfc+dy9tiS+nP2T4nBeWj4/IbnalpWXfsleccC3c4=";
  };

  # B-Trust's PDF registers libeTPkcs11.so.  SafeNet ships both that generic
  # eToken module and the IDPrime-specific one; use the latter for the
  # IDPrime 940 card.  Both expose the same token.
  p11Lib = "${pkgs.pcsc-safenet}/lib";

  # trust: NSS SSL,S/MIME,JAR flags.  "CT" = trusted CA for both server and
  # client auth; intermediates only need to be present, not trusted.
  certificates = [
    {
      nickname = "B-Trust Root Qualified CA";
      file = btrustRootQca;
      trust = "CT,,";
    }
    {
      nickname = "B-Trust Operational Qualified CA";
      file = btrustOperationalQca;
      trust = ",,";
    }
  ];

  importCert = cert: ''
    if ! ${pkgs.nssTools}/bin/certutil -L -d sql:"$nssdb" -n ${lib.escapeShellArg cert.nickname} >/dev/null 2>&1; then
      ${pkgs.nssTools}/bin/certutil -A -d sql:"$nssdb" \
        -n ${lib.escapeShellArg cert.nickname} \
        -t ${lib.escapeShellArg cert.trust} \
        -i ${cert.file}
    fi
  '';
in
{
  # Stable directory registered in NSS; home.file keeps the symlink current
  # when pcsc-safenet changes in the store.  Link the whole lib directory, not
  # just the module: the Gemalto library loads its token engine from $ORIGIN,
  # which would otherwise resolve to this directory in the home and find
  # nothing.
  home.file.".local/lib/btrust".source = p11Lib;

  # Close Chromium before the first switch: writing to the NSS database while
  # it is open can corrupt it.  If Chromium is running we skip the setup (the
  # Home Manager activation service runs again at the next login), and later
  # switches are read-only unless a module/certificate is missing.
  #
  # This must run after `linkGeneration`: that is the step that creates the
  # `~/.local/lib/btrust` symlink above, and `modutil` needs the library to be
  # loadable while it registers the module.
  home.activation.btrust-nss = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    nssdb="$HOME/.pki/nssdb"
    module="$HOME/.local/lib/btrust/libIDPrimePKCS11.so"

    if ${pkgs.procps}/bin/pgrep -u "$(${pkgs.coreutils}/bin/id -u)" -x chromium >/dev/null 2>&1 \
       || ${pkgs.procps}/bin/pgrep -u "$(${pkgs.coreutils}/bin/id -u)" -x chrome >/dev/null 2>&1; then
      echo "btrust-nss: Chromium is running; close it and run 'home-manager switch' (or log out and back in) to finish the NSS setup." >&2
    else
      ${pkgs.coreutils}/bin/mkdir -p "$nssdb"

      if [ ! -f "$nssdb/cert9.db" ]; then
        ${pkgs.nssTools}/bin/certutil -N --empty-password -d sql:"$nssdb"
      fi

      if ! ${pkgs.nssTools}/bin/modutil -dbdir sql:"$nssdb" -list 2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep -Fq "library name: $module"; then
        ${pkgs.nssTools}/bin/modutil -force -dbdir sql:"$nssdb" \
          -add "B-Trust IDPrime" -libfile "$module" -mechanisms FRIENDLY
      fi

      ${lib.concatMapStringsSep "\n" importCert certificates}

      # An earlier revision also imported the BISS localhost root.  Remove it
      # again so Chromium only trusts the B-Trust qualified chain.
      if ${pkgs.nssTools}/bin/certutil -L -d sql:"$nssdb" -n 'BISS Root localhost' >/dev/null 2>&1; then
        ${pkgs.nssTools}/bin/certutil -D -d sql:"$nssdb" -n 'BISS Root localhost'
      fi
    fi
  '';
}
