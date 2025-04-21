# Prompt Configuration README

This document explains how to configure a unified, JSON‑driven prompt across multiple shells by placing per‑shell loader scripts in `~/.config/shell/prompt/` and sourcing them from your rc/profile files.

---

## 1. Prerequisites

- **JSON config**: `~/.config/shell/prompt/config.json` (see example below).
- **Parser tools**:
  - **jq** (POSIX shells): [jq Manual](https://stedolan.github.io/jq/manual/)
  - **PowerShell**: built‑in `ConvertFrom‑Json` cmdlet ([docs](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/convertfrom-json))
  - **Python**: built‑in `json` module ([docs](https://docs.python.org/3/library/json.html))
  - **Nushell**: `open … | from json` pipeline ([docs](https://www.nushell.sh/book/pipelines.html#json))
  - **Xonsh**: Python environment with `json` module ([tutorial](https://xon.sh/tutorial.html#customizing-the-prompt))

---

## 2. JSON Configuration Example

Save this as `~/.config/shell/prompt/config.json`:

```json
{
  "colors": {
    "reset":     "\u001b[0m",
    "black":     "\u001b[30m",
    "red":       "\u001b[31m",
    "green":     "\u001b[32m",
    "yellow":    "\u001b[33m",
    "blue":      "\u001b[34m",
    "magenta":   "\u001b[35m",
    "cyan":      "\u001b[36m",
    "white":     "\u001b[37m",
    "bright_black":   "\u001b[90m",
    "bright_red":     "\u001b[91m",
    "bright_green":   "\u001b[92m",
    "bright_yellow":  "\u001b[93m",
    "bright_blue":    "\u001b[94m",
    "bright_magenta": "\u001b[95m",
    "bright_cyan":    "\u001b[96m",
    "bright_white":   "\u001b[97m",
    "bold":      "\u001b[1m",
    "dim":       "\u001b[2m",
    "underline": "\u001b[4m",
    "reverse":   "\u001b[7m"
  },
  "prompt": {
    "ps1":  "{reset}{cyan}{user}@{hostname}{blue}:{cwd}{branch_mark}{reset} {red}{exit_code}{reset}{bold}{branch_mark}{reset}\n› ",
    "ps2":  "{reset}{bold}…{reset} ",
    "ps3":  "{reset}{cyan}?{blue}:{reset} ",
    "ps4":  "{reset}{red}+{reset} "
  }
}
```

The `colors` block now includes all 16 ANSI text colors plus common styles (bold, dim, underline, reverse), and the `prompt` block continues to define **PS1**, **PS2**, **PS3**, and **PS4**.

---

## 3. Loader Scripts & rc‑file Entries

Each loader script will **dynamically** read *all* colors from the JSON rather than hard‑coding them. Place them in `~/.config/shell/prompt/` and source from your rc/profile.

### prompt.bash (bash, dash, sh)

```bash
#!/usr/bin/env sh
# prompt.bash (bash, dash, sh)
cfg="$HOME/.config/shell/prompt/config.json"
if command -v jq > /dev/null 2>&1; then
  # Core placeholders (POSIX-compatible)
  user="$(whoami)"
  hostname="$(hostname)"
  cwd="$(pwd)"
  exit_code="$(if [ $? -ne 0 ]; then printf '[%d]' "$?"; fi)"

  # Load all colors into shell variables
  for col in $(jq -r '.colors | keys | .[]' "$cfg"); do
    eval "$col=\"$(jq -r .colors.\"$col\" \"$cfg\")\""
  done

  # Load prompt templates
  ps1_tpl=$(jq -r .prompt.ps1 "$cfg")
  ps2_tpl=$(jq -r .prompt.ps2 "$cfg")
  ps3_tpl=$(jq -r .prompt.ps3 "$cfg")
  ps4_tpl=$(jq -r .prompt.ps4 "$cfg")

  # Export PS1–PS4 with variable expansion
  PS1=$(eval printf "%s" "$ps1_tpl")
  PS2=$(eval printf "%s" "$ps2_tpl")
  PS3=$(eval printf "%s" "$ps3_tpl")
  PS4=$(eval printf "%s" "$ps4_tpl")

  export PS1 PS2 PS3 PS4
fi
```

**Add to** `~/.bashrc`, `~/.zshrc`, `~/.profile`, or `/etc/profile`:

```bash
source ~/.config/shell/prompt/prompt.bash
```

---

### prompt.zsh (zsh-specific)

```zsh
#!/usr/bin/env zsh
cfg="$HOME/.config/shell/prompt/config.json"
if command -v jq &>/dev/null; then
  # Load all colors into associative array
  typeset -A colors
  for col in $(jq -r '.colors | keys | .[]' "$cfg"); do
    colors[$col]=$(jq -r .colors.$col "$cfg")
  done

  # Load prompt templates
  ps1_tpl=$(jq -r .prompt.ps1 "$cfg")
  ps2_tpl=$(jq -r .prompt.ps2 "$cfg")
  ps3_tpl=$(jq -r .prompt.ps3 "$cfg")
  ps4_tpl=$(jq -r .prompt.ps4 "$cfg")

  # Assign prompts (expand via eval)
  PROMPT=$(eval echo "\"$ps1_tpl\"")
  PS2=$(eval echo "\"$ps2_tpl\"")
  PS3=$(eval echo "\"$ps3_tpl\"")
  PS4=$(eval echo "\"$ps4_tpl\"")
fi
```

**Add to** `~/.zshrc`:

```zsh
source ~/.config/shell/prompt/prompt.zsh
```

---

### prompt.tcsh (tcsh)

```tcsh
#!/usr/bin/env tcsh
set cfg = ~/.config/shell/prompt/config.json
if ( $?jq ) then
  # User, host, cwd
  set user = `whoami`
  set hostname = `hostname`
  set cwd = '%~'
  set exitpc = '`if ( $? != 0 ) then echo "[$?]"; endif`'

  # Load all colors
  foreach col (`jq -r '.colors | keys | .[]' $cfg`)
    eval "set $col = `jq -r .colors.$col \"$cfg\"`"
  end

  # Load prompts
  foreach ps (ps1 ps2 ps3 ps4)
    eval "set ${ps}tpl = `jq -r .prompt.$ps \"$cfg\"`"
  end

  # Assign
  set prompt  = `eval echo "\"$ps1tpl\""`
  set prompt2 = `eval echo "\"$ps2tpl\""`
  set prompt3 = `eval echo "\"$ps3tpl\"""`
  set prompt4 = `eval echo "\"$ps4tpl\"""`
endif
```

**Add to** `~/.tcshrc`:

```tcsh
source ~/.config/shell/prompt/prompt.tcsh
```

---

### prompt.xsh (xonsh)

```python
import json, os, socket
cfg = json.load(open(os.path.expanduser('~/.config/shell/prompt/config.json')))
# Helper to format templates
_fmt = lambda t, **k: t.format(**k)

def _myprompt():
    # Build keyword dict with all colors + context
    kw = dict(cfg['colors'],
        user=os.environ['USER'], hostname=socket.gethostname(), cwd=os.getcwd(),
        branch_mark=f"({__xonsh__.env.get('GIT_BRANCH','')})" if __xonsh__.env.get('GIT_BRANCH') else '',
        exit_code=f"[{__xonsh__.env.get('EXIT_CODE',0)}]" if __xonsh__.env.get('EXIT_CODE',0) else ''
    )
    return _fmt(cfg['prompt']['ps1'], **kw)

$PROMPT = _myprompt
$SECOND_PROMPT = lambda: _fmt(cfg['prompt']['ps2'], **dict(cfg['colors']))
```

Place `prompt.xsh` in `~/.config/xonsh/rc.d/` (no manual sourcing needed).

---

### prompt.ps1 (PowerShell)

```powershell
$config = Get-Content "$HOME/.config/shell/prompt/config.json" -Raw | ConvertFrom-Json
function global:prompt {
  # Build hashtable with colors + context
  $h = @{}
  $config.colors.PSObject.Properties | ForEach-Object { $h[$_.Name] = $_.Value }
  $h.user = [Environment]::UserName
  $h.hostname = [Environment]::MachineName
  $h.cwd = (Get-Location).Path
  $h.exit_code = if ($LASTEXITCODE -ne 0) { "[$LASTEXITCODE]" } else { "" }

  return $config.prompt.ps1 -f $h
}
function global:prompt2 { $config.prompt.ps2 }
function global:prompt3 { $config.prompt.ps3 }
function global:prompt4 { $config.prompt.ps4 }
```

**Add to** `Microsoft.PowerShell_profile.ps1`:

```powershell
. ~/.config/shell/prompt/prompt.ps1
```

---

### prompt.nu (Nushell)

```nu
let cfg = (open ~/.config/shell/prompt/config.json | from json)
# Define prompt1 using all colors
def prompt1 [] {
  let c = $cfg.colors\ n  let mark = (if $status.code != 0 {"[$status.code]"} else {""})
  $"($c.reset)$env.USER@$($sys.host.name):$(pwd.name)$mark$c.reset$c.cyan›$c.reset "
}
# Prompt2 (continuation)
def prompt2 [] { $(ansi $cfg.colors.bold)…$(ansi $cfg.colors.reset) }
$env.prompt = { prompt1 }
# Nushell lacks PS3/PS4 equivalents
```

---

## 4. Verification

1. Open a fresh session of each shell.
2. Ensure **PS1/PS2/PS3/PS4** (where supported) reflect the JSON settings.
3. Run a failing command (`false`) to verify the red exit‑code marker.

With this setup—**all** ANSI colors and styles defined centrally in JSON, plus shell‑specific loaders that auto‑import every color—you’ll have a consistent, easily‑customizable prompt across **bash**, **dash**, **sh**, **zsh**, **tcsh**, **xonsh**, **PowerShell**, and **Nushell**.
