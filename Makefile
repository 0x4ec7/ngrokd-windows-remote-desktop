.PHONY: build certs client

help:
	@echo "  help     Display this message."
	@echo "  build    Build ngrokd docker image."
	@echo "  certs    Copy certificates from inside of the container."
	@echo "  client   Copy client from inside of the container."

build:
	docker-compose build

certs:
	docker run --rm --entrypoint="" -i -v ${PWD}:/ngrok ngrokd:latest bash -c "cp -R assets /ngrok/"

client:
	docker run --rm --entrypoint="" -i -v ${PWD}:/ngrok ngrokd:latest bash -c "cp -R bin/windows_amd64 /ngrok/bin/"
