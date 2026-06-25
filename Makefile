DB_URL=postgresql://root:secret@localhost:5432/simplebank?sslmode=disable


postgres:
	docker run --name postgres12-simplebank --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

postgresstart:
	docker start postgres12-simplebank

cleandb:
	$(MAKE) migratedown
	$(MAKE) migrateup

createdb:
	docker exec -it postgres12-simplebank createdb --username=root --owner=root simplebank

dropdb:
	docker exec -it postgres12-simplebank dropdb simplebank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

newmigration:
	migrate create -ext sql -dir db/migration -seq "$(name)"

sqlc:
	sqlc generate

test:
	go test -v -count=1 -cover -short ./...

start:
	go run main.go

restart:
	docker compose down
	docker rmi simplebank-api:latest
	docker compose up --watch

mock:
	mockgen -package mockdb -destination db/mock/store.go 			github.com/michalski30/simplebank/db/sqlc Store
	mockgen -package mockwk -destination worker/mock/distributor.go github.com/michalski30/simplebank/worker TaskDistributor

git:
	git add . && git commit -m "$(CM)" && git push

docsdb:
	dbdocs build doc/db.dbml

schemadb:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

startfromscratchpostgres:
	docker run --name postgres12 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine
	docker exec -it postgres12 createdb --username=root --owner=root simple_bank
	migrate -path db/migration -database "$(DB_URL)" -verbose up

proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
    --go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simplebank \
    proto/*.proto
	statik -src=./doc/swagger -dest=./doc

evans:
	evans --host localhost --port 9090 -r repl

redis:
	docker run --name redis -p 6379:6379 -d redis:8-alpine

# -----------------------------------------------------------------------

mock2:
	cd db/sqlc && mockgen -destination ../mock/store.go . startfromscratchpostgres


.PHONY: postgres postgresstart cleandb createdb dropdb migrateup migrateup1 migratedown migratedown1 newmigration sqlc test start restart mock docsdb schemadb git proto evans redis