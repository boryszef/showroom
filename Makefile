IMAGENAME = "imgtec"
SERVERNAME = "test.com"
PASSWORD = "mypass"

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

image: Dockerfile.in
	sed 's/@SERVERNAME@/$(SERVERNAME)/' Dockerfile.in > Dockerfile
	sed 's/@PASSWORD@/$(PASSWORD)/' Dockerfile.in > Dockerfile
	docker build --no-cache -t $(IMAGENAME) .

tests: runtests.py
	virtualenv venv
	( \
		export IMAGENAME="$(IMAGENAME)"; \
	       	export PASSWORD="$(PASSWORD)"; \
		source venv/bin/activate; \
		pip install paramiko; \
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
