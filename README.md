## Dotfiles Config

This configuration script will set up the bulk of the configuration needed
for my mac. The system has the following setup:

```
dotfiles/
|- bin/
|--- sys
|- src/
|--- 01_brew/
|--- 02_toolchain/
|--- 03_macos/
|--- 04_config/
|--- main.sh
|--- utils.sh
```

The file `bin/sys` is an executable that when put on the `PATH` will update and
sync the system. The `src/` directory contains the different configuration
types needed. These include installing command line tools, setting up brew 
packages, casks, and `mas` applications, setting up toolchains for systems such
as rust, python, node, and julia, syncing macOS settings, and symlinking
various configuration files.

Here is the help command for sys:

```bash
 sys - System Management Tool

Usage: sys <command> [options]

Commands:
    update            Update everything (same as 'sys sync --all')
    brew              Manage Homebrew packages
        update        Update Homebrew and packages
        reinstall     Reinstall all Homebrew packages

    dev               Manage development toolchains
        update        Update all development tools
        reinstall     Reinstall all development tools

    macos             Manage macOS settings
        apply         Apply macOS system settings
        reset         Reset macOS settings to defaults

    config            Manage configuration files
        sync          Sync configuration files
        clean         Remove broken symlinks

    sync              Selectively sync system components
        --all         Sync everything (default if no flags)
        --brew        Sync Homebrew packages
        --toolchain   Sync development toolchains
        --macos       Sync macOS settings
        --config      Sync configuration files

Options:
    -f, --force       Force operations (reinstall/overwrite)
    -d, --dry-run     Show what would be done
    -v, --verbose     Show detailed output
    -h, --help        Show this help message

Examples:
    sys update                  # Update everything
    sys brew update             # Update Homebrew packages
    sys dev reinstall           # Reinstall development tools
    sys config sync             # Sync config files
    sys sync --brew --dev       # Update Homebrew and dev tools
    sys sync --all --force      # Force update everything
```



