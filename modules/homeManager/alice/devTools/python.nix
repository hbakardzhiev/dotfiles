{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (python312.withPackages (
      p: with p; [
        pandas
        numpy
        statsmodels
        requests
        scipy
        matplotlib
        scikit-learn
        seaborn
      ]
    ))

    # python311Packages.pandas
    # python311Packages.numpy
    # python311Packages.statsmodels
  ];
}
