{ path, lib, ... }:
let
  # Helper function to recursively find all .nix files
  findNixFiles =
    dir:
    let
      contents = builtins.readDir dir;
      files = builtins.attrNames contents;
      # Function to determine if a path is a directory
      isDir = dirToCheck: lib.filesystem.pathIsDirectory dirToCheck;
      # Function to check if a file has a .nix extension
      isNixFile = file: builtins.match ".*\\.nix$" file != null;
    in
    builtins.concatLists (
      map (
        file:
        if isNixFile file then
          [ "${dir}/${file}" ]
        else if isDir "${dir}/${file}" then
          findNixFiles "${dir}/${file}"
        else
          [ ]
      ) files
    );

  # Use the helper function to get all .nix files recursively
  allNixFiles = findNixFiles path;
in
allNixFiles
