#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../utils.sh"

if [[ "${INSTALL_NODE_SOURCED-}" != "true" ]]; then
    INSTALL_NODE_SOURCED=true

    install_node() {
        print_status "Setting up Node.js environment..."

        # Install nvm if not present
        if [ ! -d "$HOME/.nvm" ]; then
            print_status "Installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            
            # Load nvm for current session
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        else
            print_status "nvm already installed, updating..."
            (
                cd "$HOME/.nvm"
                git fetch --tags origin
                git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
            )
        fi

        # Ensure nvm is loaded
        if ! command -v nvm &> /dev/null; then
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        fi

        # Install latest LTS version of Node.js
        print_status "Installing latest Node.js LTS version..."
        nvm install --lts
        nvm use --lts
        nvm alias default 'lts/*'

        # Install global npm packages
        print_status "Installing global npm packages..."
        npm_packages=(
            "typescript"
            "ts-node"
            "@types/node"
            "prettier"
            "eslint"
            "@typescript-eslint/parser"
            "@typescript-eslint/eslint-plugin"
            "tsx"
            "npm-check-updates"
        )

        for package in "${npm_packages[@]}"; do
            print_status "Installing/updating $package..."
            npm install -g "$package"
        done

        # Create default TypeScript configuration if it doesn't exist
        if [ ! -f "$HOME/.tsconfig.json" ]; then
            print_status "Creating default TypeScript configuration..."
            cat > "$HOME/.tsconfig.json" << EOL
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
EOL
        fi

        # Create default ESLint configuration if it doesn't exist
        if [ ! -f "$HOME/.eslintrc.json" ]; then
            print_status "Creating default ESLint configuration..."
            cat > "$HOME/.eslintrc.json" << EOL
{
  "env": {
    "browser": true,
    "es2022": true,
    "node": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "plugins": [
    "@typescript-eslint"
  ],
  "rules": {
    "indent": ["error", 2],
    "linebreak-style": ["error", "unix"],
    "quotes": ["error", "single"],
    "semi": ["error", "always"]
  }
}
EOL
        fi

        print_success "Node.js toolchain installation/update complete!"
        return 0
    }
fi

