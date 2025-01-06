include .env
RUN = docker-compose run --no-deps --rm -u root mapservermr

build:
	docker build -t mapservermr:0.1 .

rebuild: stop build start ps

start:
	@docker-compose up -d

stop:
	@docker-compose down

restart: stop start

ps:
	@docker-compose ps

consola:
	./conf/shell-localhost.sh

logs:
	@docker-compose logs

run-sudo:
	${RUN} /bin/bash

save-image:
	docker save -o /tmp/clum.tar w2p-docker:0.1
	echo """scp /tmp/clum.tar root@t-clum.rosario.gov.ar:/tmp/"""
	echo """docker load -i /tmp/clum.tar"""
