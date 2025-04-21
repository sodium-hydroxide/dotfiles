#!/usr/bin/env sh
# Use for dash, bash, sh
cfg="$HOME/.config/shell/prompt/config.json"
if command -v jq &>/dev/null; then
  # Core placeholders
  user='\u'; hostname='\h'; cwd='\w'
  exit_code='$(if [ $? -ne 0 ]; then echo "[\$?]"; fi)'

  # Load all colors into shell variables
  for col in $(jq -r '.colors | keys | .[]' "$cfg"); do
    eval "$col=\"$(jq -r .colors."$col" "$cfg")\""
  done

  # Load prompt templates
  ps1_tpl=$(jq -r .prompt.ps1 "$cfg")
  ps2_tpl=$(jq -r .prompt.ps2 "$cfg")
  ps3_tpl=$(jq -r .prompt.ps3 "$cfg")
  ps4_tpl=$(jq -r .prompt.ps4 "$cfg")

  # Export PS1–PS4 with variable expansion
  export PS1=$(eval echo "\"$ps1_tpl\"")
  export PS2=$(eval echo "\"$ps2_tpl\"")
  export PS3=$(eval echo "\"$ps3_tpl\"")
  export PS4=$(eval echo "\"$ps4_tpl\"")
fi
