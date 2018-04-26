IMAGENAME = imgtec
SERVERNAME = test.com
PASSWORD = mypass
MAXCONNECTIONS = 1000

default:
	@echo
	@echo "Usage:"
	@echo
	@echo "make all           - do all steps"
	@echo "make image         - prepare image using Dockerfile"
	@echo "make tests         - run tests"
	@echo "make clean         - cleanup everything"
	@echo
	@echo "Variables used (and defaults):"
	@echo "IMAGENAME ($(IMAGENAME))"
	@echo "SERVERNAME ($(SERVERNAME))"
	@echo "PASSWORD ($(PASSWORD))"
	@echo

all: image tests

Dockerfile: Dockerfile.in
	sed 's/@SERVERNAME@/$(SERVERNAME)/' Dockerfile.in > Dockerfile
	sed 's/@PASSWORD@/$(PASSWORD)/' Dockerfile.in > Dockerfile

$(IMAGENAME).log:
	docker build --no-cache --rm --force-rm -t $(IMAGENAME) . > $(IMAGENAME).log

image: Dockerfile $(IMAGENAME).log

run: image
	docker run -d -p 2222:22 -p 8080:80 -t imgtec

venv:
	virtualenv venv
	( \
		source venv/bin/activate; \
		pip install paramiko; \
		deactivate; \
	)

tests: image venv runtests.py
	( \
		export IMAGENAME="$(IMAGENAME)"; \
	       	export PASSWORD="$(PASSWORD)"; \
	       	export MAXCONNECTIONS="$(MAXCONNECTIONS)"; \
		source venv/bin/activate; \
		python runtests.py; \
		deactivate; \
	)

clean:
	containers="$(shell docker ps -a -q)"
ifneq ($(containers), )
	docker rm $(containers)
endif
	images="$(shell docker images -q)"
ifneq ($(images), )
	docker rmi $(images)
endif
	rm -f Dockerfile
	rm -rf venv
	rm -f $(IMAGENAME).log
