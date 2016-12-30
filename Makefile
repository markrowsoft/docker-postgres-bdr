all: build

build:
	@docker build --tag=markrowsoft/postgresql-bdr .

release: build
	@docker build --tag=markrowsoft/postgresql-bdr:$(shell cat VERSION) .
