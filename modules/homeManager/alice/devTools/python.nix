{ pkgs, ... }: {
  home.packages = with pkgs; [
    (python311.withPackages (p: with p; [
      pandas
      numpy
      statsmodels      
      requests
    ]))

    
    # python311Packages.pandas
    # python311Packages.numpy
    # python311Packages.statsmodels
  ];
}
