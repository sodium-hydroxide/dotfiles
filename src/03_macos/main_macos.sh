#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../utils.sh"

check_defaults() {
    local domain=$1
    local key=$2
    local expected=$3
    local current

    current=$(defaults read "$domain" "$key" 2>/dev/null)
    if [ $? -eq 0 ] && [ "$current" == "$expected" ]; then
        return 0  # matches
    fi
    return 1  # doesn't match or couldn't read
}

check_mapping() {
    local current_mapping
    current_mapping=$(hidutil property --get "UserKeyMapping" 2>/dev/null)
    if [[ $current_mapping == *"HIDKeyboardModifierMappingSrc\":0x700000039,\"HIDKeyboardModifierMappingDst\":0x700000029"* ]]; then
        return 0  # mapping exists
    fi
    return 1  # mapping doesn't exist
}

write_defaults() {
    local domain=$1
    local key=$2
    local value=$3
    local type=$4  # -bool, -int, -string, -float

    if ! check_defaults "$domain" "$key" "$value"; then
        print_status "Updating $domain $key to $value"

        # First try without sudo (user preferences)
        defaults write "$domain" "$key" "$type" "$value"

        # Only use sudo for system-level preferences
        case "$domain" in
            "/Library/Preferences/"* | \
            "com.apple.loginwindow" | \
            "com.apple.WindowManager" | \
            "/Library/Preferences/SystemConfiguration/"*)
                sudo defaults write "$domain" "$key" "$type" "$value"
                ;;
            # For Dock and Finder, write to both user and system domains
            "com.apple.dock" | "com.apple.finder")
                defaults write "$domain" "$key" "$type" "$value"
                sudo defaults write "/Library/Preferences/$domain" "$key" "$type" "$value" 2>/dev/null || true
                ;;
        esac
        return 0  # change made
    fi
    return 1  # no change needed
}

main_macos() {
    local needs_dock_restart=0
    local needs_finder_restart=0
    local needs_ui_restart=0

    print_status "Checking keyboard settings..."
    # Set key repeat rate (lower number is faster)
    write_defaults -g "KeyRepeat" "2" "-int" && needs_ui_restart=1
    # Disable press-and-hold for keys in favor of key repeat
    write_defaults -g "ApplePressAndHoldEnabled" "false" "-bool" && needs_ui_restart=1
    # Set function key behavior (0 = F1-F12 keys work as standard function keys)
    write_defaults "com.apple.HIToolbox" "AppleFnUsageType" "0" "-int" && needs_ui_restart=1

    # Remap caps lock key to escape
    if ! check_mapping; then
        print_status "Updating keyboard mapping"
        hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'
    fi

    print_status "Checking global preferences..."
    # Use metric system
    write_defaults -g "AppleMetricUnits" "1" "-int"
    # Set measurement units to centimeters
    write_defaults -g "AppleMeasurementUnits" "Centimeters" "-string"
    # Use Celsius for temperature
    write_defaults -g "AppleTemperatureUnit" "Celsius" "-string"
    # Use 24-hour time
    write_defaults -g "AppleICUForce24HourTime" "true" "-bool"
    # Disable "natural" scroll direction
    write_defaults -g "com.apple.swipescrolldirection" "false" "-bool"
    # Disable automatic spelling correction
    write_defaults -g "NSAutomaticSpellingCorrectionEnabled" "false" "-bool"
    # Disable automatic capitalization
    write_defaults -g "NSAutomaticCapitalizationEnabled" "false" "-bool"
    # Disable automatic period substitution
    write_defaults -g "NSAutomaticPeriodSubstitutionEnabled" "false" "-bool"
    # Disable automatic dash substitution
    write_defaults -g "NSAutomaticDashSubstitutionEnabled" "false" "-bool"
    # Disable automatic quote substitution
    write_defaults -g "NSAutomaticQuoteSubstitutionEnabled" "false" "-bool"

    print_status "Checking dock settings..."
    # Keep Dock always visible
    write_defaults "com.apple.dock" "autohide" "false" "-bool" && needs_dock_restart=1
    # Disable opening application animations
    write_defaults "com.apple.dock" "launchanim" "false" "-bool" && needs_dock_restart=1
    # Set maximum Dock size when magnified
    write_defaults "com.apple.dock" "largesize" "32" "-int" && needs_dock_restart=1
    # Enable Dock magnification on hover
    write_defaults "com.apple.dock" "magnification" "true" "-bool" && needs_dock_restart=1
    # Set default Dock size
    write_defaults "com.apple.dock" "tilesize" "24" "-int" && needs_dock_restart=1
    # Set minimize/maximize window animation effect
    write_defaults "com.apple.dock" "mineffect" "scale" "-string" && needs_dock_restart=1
    # Don't minimize windows into their application icon
    write_defaults "com.apple.dock" "minimize-to-application" "false" "-bool" && needs_dock_restart=1
    # Don't automatically rearrange Spaces based on most recent use
    write_defaults "com.apple.dock" "mru-spaces" "false" "-bool" && needs_dock_restart=1
    # Position Dock on the left side of the screen
    write_defaults "com.apple.dock" "orientation" "left" "-string" && needs_dock_restart=1
    # Show indicators for open applications
    write_defaults "com.apple.dock" "show-process-indicators" "true" "-bool" && needs_dock_restart=1
    # Don't show recent applications in Dock
    write_defaults "com.apple.dock" "show-recents" "false" "-bool" && needs_dock_restart=1
    # Hot corners
    write_defaults "com.apple.dock" "wvous-bl-corner" "1" "-int" && needs_dock_restart=1
    write_defaults "com.apple.dock" "wvous-br-corner" "4" "-int" && needs_dock_restart=1
    write_defaults "com.apple.dock" "wvous-tl-corner" "1" "-int" && needs_dock_restart=1
    write_defaults "com.apple.dock" "wvous-tr-corner" "1" "-int" && needs_dock_restart=1
    # Don't group windows by application in Mission Control
    write_defaults "com.apple.dock" "expose-group-by-app" "false" "-bool" && needs_dock_restart=1
    # Mission Control animation speed
    write_defaults "com.apple.dock" "expose-animation-duration" "0.1" "-float" && needs_dock_restart=1
    # Disable window snapping
    write_defaults "com.apple.dock" "window-snap" "false" "-bool" && needs_dock_restart=1

    print_status "Checking finder settings..."
    # Set preferred view style (list view)
    write_defaults "com.apple.finder" "FXPreferredViewStyle" "Nlsv" "-string" && needs_finder_restart=1
    # Show full path in Finder title
    write_defaults "com.apple.finder" "_FXShowPosixPathInTitle" "true" "-bool" && needs_finder_restart=1
    # Show all filename extensions
    write_defaults "com.apple.finder" "AppleShowAllExtensions" "true" "-bool" && needs_finder_restart=1
    # Show path bar
    write_defaults "com.apple.finder" "ShowPathbar" "true" "-bool" && needs_finder_restart=1
    # Show status bar
    write_defaults "com.apple.finder" "ShowStatusBar" "true" "-bool" && needs_finder_restart=1

    print_status "Checking trackpad settings..."
    # Set light clicking pressure
    write_defaults "com.apple.AppleMultitouchTrackpad" "ActuationStrength" "0" "-int"
    # Enable tap to click
    write_defaults "com.apple.AppleMultitouchTrackpad" "Clicking" "true" "-bool"
    # Disable drag with trackpad
    write_defaults "com.apple.AppleMultitouchTrackpad" "Dragging" "false" "-bool"
    # Enable two-finger right click
    write_defaults "com.apple.AppleMultitouchTrackpad" "TrackpadRightClick" "true" "-bool"
    # Disable three-finger drag
    write_defaults "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerDrag" "false" "-bool"
    # Disable three-finger tap
    write_defaults "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerTapGesture" "0" "-int"
    # Disable force click
    write_defaults "com.apple.AppleMultitouchTrackpad" "ForceSuppressed" "true" "-bool"
    # Disable haptic feedback
    write_defaults "com.apple.AppleMultitouchTrackpad" "ActuateDetents" "false" "-bool"

    print_status "Checking other system settings..."
    # Use analog clock in menu bar
    write_defaults "com.apple.menuextra.clock" "IsAnalog" "true" "-bool" && needs_ui_restart=1
    # Don't show screenshot thumbnail
    write_defaults "com.apple.screencapture" "show-thumbnail" "false" "-bool"
    # Disable automatic macOS updates
    write_defaults "com.apple.SoftwareUpdate" "AutomaticallyInstallMacOSUpdates" "false" "-bool"
    # Disable click to show desktop
    write_defaults "com.apple.WindowManager" "EnableStandardClickToShowDesktop" "false" "-bool" && needs_ui_restart=1

    # Only restart services if changes were made
    if [ $needs_dock_restart -eq 1 ]; then
        print_status "Restarting Dock..."
        killall Dock
        # Wait for Dock to restart
        sleep 2
        if ! pgrep -x "Dock" > /dev/null; then
            print_status "Dock didn't restart automatically, launching it..."
            /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock &
        fi
    fi

    if [ $needs_finder_restart -eq 1 ]; then
        print_status "Restarting Finder..."
        killall Finder
    fi

    if [ $needs_ui_restart -eq 1 ]; then
        print_status "Restarting SystemUIServer..."
        killall SystemUIServer
        # Reload preference cache
        killall cfprefsd
    fi

    print_status "Setting Default files"
    duti "$CURRENT_DIR/../03_macos/duti"

    print_status "Configuration check complete!"
}
