NAME=registrator
VERSION=$(shell cat VERSION)

dev:
	docker build -f Dockerfile.dev -t $(NAME):dev .
	docker run --rm \
		-v /var/run/docker.sock:/tmp/docker.sock \
		$(NAME):dev /bin/registrator consul:

build:
	mkdir -p build
	docker build -t $(NAME):$(VERSION) .
	docker save $(NAME):$(VERSION) | gzip -9 > build/$(NAME)_$(VERSION).tgz

release:
	rm -rf release && mkdir release
	go get github.com/progrium/gh-release/...
	cp build/* release
	gh-release create gliderlabs/$(NAME) $(VERSION) \
		$(shell git rev-parse --abbrev-ref HEAD) $(VERSION)
	glu hubtag gliderlabs/$(NAME) $(VERSION)

docs:
	docker run --rm -it -p 8000:8000 -v $(PWD):/work gliderlabs/pagebuilder mkdocs serve

circleci:
	rm -f ~/.gitconfig
	go get -u github.com/gliderlabs/glu
	glu circleci

build-deps:
	go get github.com/coreos/etcd
	go get github.com/coreos/go-etcd
	go get github.com/coreos/go-etcd/etcd
	go get github.com/hashicorp/consul
	go get gopkg.in/coreos/go-etcd.v0
	go get github.com/fsouza/go-dockerclient
	go get github.com/cenkalti/backoff
	go get github.com/ugorji/go/codec

.PHONY: build release docs
