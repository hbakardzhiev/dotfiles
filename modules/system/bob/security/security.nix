{
  ...
}:
{
  sops.secrets.tor_bridges = {
    # Optional: Set owner to the tor user for better security
    owner = "tor";
  };

}
