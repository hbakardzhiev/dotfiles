{ ... }:
{
  # For GPU mining
  # services.cgminer = {
  #   enable = true;
  #   pools = [
  #     {
  #       pass = "x";
  #       url = "stratum+tcp://mine.ocean.xyz:3334";
  #       user = "bc1qnslwaadh4n993uzg0hvsv8dn3029xhgfd4826c";  
  #     }
  #   ];
  #   user = "alice";
  #   config = {
  #     auto-fan = true;
  #   };
  # };

  # For CPU mining but error in the current version   
  # services.cpuminer-cryptonight = {
  #   enable = true;
  #   url = "stratum+tcp://mine.ocean.xyz:3334";
  #   threads = 2;
  #   user = "bc1qnslwaadh4n993uzg0hvsv8dn3029xhgfd4826c";  
  # };
}
