#!/bin/sh

sudo mkdir -p /opt/uv
sudo chown -R $(whoami):admin /opt/uv
curl -LsSf https://astral.sh/uv/install.sh | sh
