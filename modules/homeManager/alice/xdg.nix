{ pkgs, ... }:
let
  browser = [
    "brave-browser.desktop"
    "floorp.desktop"
  ];
  fileManager = [ "org.kde.dolphin.desktop" ];
  imageViewer = [ "org.gnome.Loupe.desktop" ];
  editor = [ "Helix.desktop" ];
  obsidian = [ "obsidian.desktop" ];
  pdfReader = [
    "org.pwmt.zathura.desktop"
    "okularApplication_pdf.desktop"
  ];
  dict = {
    "application/pdf" = pdfReader;
    "application/epub+zip" = pdfReader;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "text/html" = browser;
    "image/svg+xml" = browser;
    "image/jpeg" = imageViewer;
    "image/gif" = imageViewer;
    "image/png" = imageViewer;
    "image/heic" = imageViewer;
    "application/xml" = editor;
    "text/markdown" = obsidian ++ editor;
    "inode/directory" = fileManager;
    "application/x-gnome-saved-search" = fileManager;
    "application/zip" = [ "org.gnome.FileRoller.desktop" ];
  };
in
{
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = dict;
      # associations.added = dict;
    };
  };
  home.packages = [ pkgs.xdg-utils ];
}
