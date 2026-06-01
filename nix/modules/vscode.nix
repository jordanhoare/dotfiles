{ pkgs, ... }:

let
  vscodeUserDir = if pkgs.stdenv.isDarwin
    then "Library/Application Support/Code/User"
    else ".config/Code/User";
in
{
  home.file = {
    "${vscodeUserDir}/settings.json".source = ../../config/Code/User/settings.json;
    "${vscodeUserDir}/keybindings.json".source = ../../config/Code/User/keybindings.json;
  };
}
