.PHONY: run
run:
	@export EXTERNAL_API_TOKEN=.token && export DB_CONN_STRING=.db_conn && export SECRET=.secret && go run cmd/*.go

.PHONY: build
build:
	@go build -o ./app cmd/*.go

.PHONY: test
test:
	go test -v -race -cover ./...

.PHONY: docker-build
docker-build:
	@docker build -t stock-service .

.PHONY: docker-run
docker-run:
	@docker run \
		--name stock-service \
		-it \
		--rm \
		-p 80:8080 \
		-v `pwd`/secret:/secret \
		-e EXTERNAL_API_TOKEN=/secret/.token \
		-e DB_CONN_STRING=/secret/.db_conn \
		-e SECRET=/secret/.jwt_secret \
		stock-service

.PHONY: docker-stop
docker-stop:
	@docker stop stock-service

.PHONY: gen-mocks
gen-mocks:
	@docker run -v `pwd`:/src -w /src vektra/mockery:v2.7 --case snake --dir internal --output internal/mock --outpkg mock --all

.PHONY: run-db
run-db:
	@docker run \
		-d \
		-v `pwd`/db:/docker-entrypoint-initdb.d/ \
		--rm \
		-p 5432:5432 \
		--name db \
		-e POSTGRES_DB=backend \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=postgres \
		postgres:12

.PHONY: run-stack
run-stack:
	@docker stack deploy -c docker-stack.yaml stock-price

.PHONY: stop-stack
stop-stack:
	@docker stack rm stock-price