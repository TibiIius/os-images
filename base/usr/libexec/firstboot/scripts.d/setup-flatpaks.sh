#!/bin/bash
set -xe

# This script sets up Flatpaks on a newly installed system

main() {
  local FLATPAK_FILE=$FILE_PATH/flatpak-done
  
  # Exit if the file exists, as this means this script probably already ran
  [[ -f "$FLATPAK_FILE" ]] && exit 0
  
  local FLATPAK_EXEC=/usr/bin/flatpak

  # Wait for internet and DNS
  until /usr/bin/ping -q -c 1 flathub.org; do sleep 1; done
  
  # Remove Fedora's filtered Flathub repo and add the default one
  $FLATPAK_EXEC remote-delete flathub --force
  $FLATPAK_EXEC remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  
  # Replace Fedora's Flatpaks with Flathub's
  $FLATPAK_EXEC install --noninteractive org.gnome.Platform//45
  $FLATPAK_EXEC install --noninteractive --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
  $FLATPAK_EXEC uninstall --noninteractive org.fedoraproject.Platform
  $FLATPAK_EXEC remote-delete fedora --force
  
  # Install some Flatpaks
  $FLATPAK_EXEC install --noninteractive flathub org.mozilla.firefox com.mattjakeman.ExtensionManager com.github.tchx84.Flatseal
  
  # Later on, we will add some more Flatpaks to this list and grab the list automatically from the web
  
  # Create file to indicate that the installation is done
  touch $FLATPAK_FILE
}
main
