## Configuration Files

The `main_config.sh` will symlink new files in this directory to their correct
locations. It will skip previously written files. The sub directories will have
their own respective READMEs as needed.

### Shell Configuration

The bashrc contains customizations to the prompt variables:

```
# PS1
username@hostname:$PWD (git status)
bash-$

# PS2
→ 

# PS3
Please choose an option:

# PS4
+scriptname:line_number: command
```

The PATH is also set manually and includes the location of homebrew binaries,
as well as the directory for cargo, julia, and python programs installed
globally. Relevant exports and aliases are also included.

There is a custom greeting for interactive shells that includes some system
information (uptime, CPU and memory load, etc) and the output of `bash --version`.

Finally, there are aliases remapping `vi` and `vim` to `nvim`, `ls` to `ls -CFl`,
`lsa` to `ls --CFla`, and `gui` to `open`.

### FreeTube Configuration

The FreeTube directory contains the settings, playlists, profiles, and history
databases which are symlinked to their correct directory. These files are version
controlled to sync across multiple computers.


### Git Configuration

The git configuration includes my name and email for commits.

### NeoVim Configuration



