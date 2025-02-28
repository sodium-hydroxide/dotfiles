SHELL=/bin/sh
HOME=/Users/noa3hjb
DOCKERFILE_DIR=$(HOME)/dotfiles/docker

.PHONY: all ide

all: ide

ide:
	docker build --pull -t ide $(DOCKERFILE_DIR)
