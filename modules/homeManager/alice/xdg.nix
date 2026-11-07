{ pkgs, ... }:
let
  browser = [
    "brave-browser.desktop"
    "floorp.desktop"
  ];
  fileManager = [ "org.gnome.Nautilus.desktop" ];
  imageViewer = [ "imv.desktop" ];
  videoPlayer = [ "mpv.desktop" ];
  editor = [ "Helix.desktop" ];
  obsidian = [ "obsidian.desktop" ];
  pdfReader = [
    "org.gnome.Evince.desktop"
    "org.pwmt.zathura.desktop"
  ];
  archive = [ "org.gnome.FileRoller.desktop" ];
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
    "image/webp" = imageViewer;
    "image/bmp" = imageViewer;
    "image/tiff" = imageViewer;
    "video/mp4" = videoPlayer;
    "video/x-matroska" = videoPlayer;
    "video/webm" = videoPlayer;
    "video/quicktime" = videoPlayer;
    "text/plain" = editor;
    "application/xml" = editor;
    "text/markdown" = obsidian ++ editor;
    "inode/directory" = fileManager;
    "application/x-gnome-saved-search" = fileManager;
    "application/zip" = archive;
  };
in
{
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = dict;
    };
  };
  home.packages = [ pkgs.xdg-utils ];
}
