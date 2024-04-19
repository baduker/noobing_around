DOCKER_IMAGE_NAME ?= star-gazer
DEFAULT_GITHUB_USER ?= baduker

# Docker related commands
build:
	@docker build -t "$(DOCKER_IMAGE_NAME)":latest .

rm:
	@docker container rm "$(DOCKER_IMAGE_NAME)" --force

prune:
	@docker system prune --all --force

clean:
	@docker images | grep none | awk '{print $3;}' | xargs docker rmi --force

run:
	@docker run -it \
		--name "$(DOCKER_IMAGE_NAME)" \
		--mount source=data,target/data \
		$(DOCKER_IMAGE_NAME) -u $(DEFAULT_GITHUB_USER)

start:
	@docker start -i "$(DOCKER_IMAGE_NAME)"

# script related commands

purge:
	@rm -rf data/*
