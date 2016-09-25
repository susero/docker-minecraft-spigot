.PHONY: build build-as-latest bind run start

IMAGE_NAME=susero/minecraft_server-spigot
IMAGE_TAG=1.10
BIND_IP=192.168.1.111
BIND_DEV=eth0
USERMAP_UID=$$(id -u)
USERMAP_GID=$$(id -g)

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

latest:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -t $(IMAGE_NAME):latest .

bind:
	sudo ip addr add $(BIND_IP) dev $(BIND_DEV)

unbind:
	sudo ip addr del $(BIND_IP)/32 dev $(BIND_DEV)

run:
	docker run -ti --rm \
		-v $$(pwd)/data:/home/spigot/data \
		-e "USERMAP_UID=$(USERMAP_UID)" \
		-e "USERMAP_GID=$(USERMAP_GID)" \
		-e "AGREE_TO_EULA=true" \
		-p $(BIND_IP):25565:25565 \
		-p $(BIND_IP):25575:25575 \
		-p $(BIND_IP):80:80 \
		-p $(BIND_IP):8123:8123 \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		bash
start:
	docker run -ti -d \
		--name spigot \
		-v $$(pwd)/data:/home/spigot/data \
		-e "USERMAP_UID=$(USERMAP_UID)" \
		-e "USERMAP_GID=$(USERMAP_GID)" \
		-e "AGREE_TO_EULA=true" \
		-p $(BIND_IP):25565:25565 \
		-p $(BIND_IP):25575:25575 \
		-p $(BIND_IP):80:80 \
		-p $(BIND_IP):8123:8123 \
		$(IMAGE_NAME):$(IMAGE_TAG)

attach:
	docker attach spigot
