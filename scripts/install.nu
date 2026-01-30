#!/usr/bin/env nu

# Copyright (c) 2025, Kira Hasegawa
# Licensed under the MIT license.

# Installer script for your dotfiles repository.

def main [
  --simulate (-n) # Do not actually make any filesystem changes
]: nothing -> nothing {
  if ($simulate) {
    log info "Simulate mode is enabled: No filesystem changes will be made."
  }

  print "Installing dotfiles from your repository..."

  # Check for git
  if (which git | is-empty) {
    log error "git seems to be not installed"
    exit 1
  }

  # Clone dotfiles repo
  let target_dir_default = $env.HOME | path join ".config/dotfiles"
  let target_dir = ask "Where do you want to install the dotfiles?" --default $target_dir_default
  if not $simulate {
    if ($target_dir | path exists) {
      log info "Updating dotfiles repository"
      git -C $target_dir pull
    } else {
      log info "Cloning dotfiles repository"
      git clone --depth 1 --recurse-submodules https://github.com/your-username/your-dotfiles-repo.git $target_dir
    }
  }

  # Perform backup
  let backup_dir_default = $env.HOME | path join $".dotfiles_backup_(random uuid -v 7)"
  let backup_dir = ask "Where do you want to store the backup?" --default $backup_dir_default
  log info "Performing backup of targeted files and directories"
  if not $simulate {
    mkdir $backup_dir
  }
  let files_to_backup = yolk eval "files_to_backup.to_json()" | from json | transpose "name" "data"
  for file in $files_to_backup {
    let path = $file.data.path
    log info $"Backing up ($path)"
    if not $simulate {
      if ($path | path type) == "symlink" {
        rm $path
      } else if ($path | path exists) {
        mv $path $backup_dir
      }
    }
  }

  # Sync dotfiles
  log info "Syncing dotfiles"
  if not $simulate {
    yolk sync
  }

  log success "Successfully installed dotfiles"
}
