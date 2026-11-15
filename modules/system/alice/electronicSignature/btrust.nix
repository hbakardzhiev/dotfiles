{
  pkgs,
  ...
}:

# B-Trust qualified electronic signature (Gemalto IDPrime 940 card in a
# Circle CCR7115 reader).  The reader is a plain CCID device, so the `ccid`
# driver that pcscd already ships is enough; no vendor reader driver is
# needed on NixOS.
let
  # B-Trust's published certification chains (PEM).
  btrustRootQca = pkgs.fetchurl {
    url = "https://ca.b-trust.org/repository/B-TrustRootQCA.cer";
    hash = "sha256-SzXLKoJh3TT8fHIPRbvCE1zPP0ndZ5tvnkLnlUVeD8w=";
  };
  btrustOperationalQca = pkgs.fetchurl {
    url = "https://ca.b-trust.org/repository/B-TrustOperationalQCA.cer";
    hash = "sha256-djkfc+dy9tiS+nP2T4nBeWj4/IbnalpWXfsleccC3c4=";
  };
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # NSS database tooling used by Chromium (also handy for debugging:
    # `modutil -dbdir sql:$HOME/.pki/nssdb -list`, `certutil -L -d ...`).
    nss
    nssTools
    opensc
    ccid
    p11-kit
    pcsc-tools
    # SafeNet Authentication Client.  Provides the Gemalto/IDPrime PKCS#11
    # middleware (`libIDPrimePKCS11.so`, `libeTPkcs11.so`, `libeToken.so`)
    # that B-Trust's instructions install as "software for your card".
    pcsc-safenet
  ];

  # Smart-card daemon (required for any reader).
  services.pcscd.enable = true;

  # Make the card visible to p11-kit-aware applications (p11tool, Java,
  # GnuTLS, ...).  Chromium does not use this file: it has its own NSS
  # database, which is configured per user in
  # modules/homeManager/alice/electronicSignature/btrust.nix.
  environment.etc."pkcs11/modules/btrust-idprime.module".text = ''
    module: ${pkgs.pcsc-safenet}/lib/libIDPrimePKCS11.so
  '';

  # Trust the B-Trust chain system-wide as well, so non-NSS tools (OpenSSL,
  # Okular, PDF validators) accept B-Trust-issued certificates.  Chromium
  # additionally needs them in ~/.pki/nssdb, which the Home Manager module
  # handles.
  security.pki.certificateFiles = [
    btrustRootQca
    btrustOperationalQca
  ];
}
