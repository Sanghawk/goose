# goose

## my reference

Docker compose

```bash
# `/infra`
docker compose up -d # composes services in detached mode
```

Postgres interactive shell

```bash
# `/infra`
docker compose exec postgres psql -U sanghawk pokerdb

\dt # see tables
\q # leave interactive mode
```

Prisma

Migration

```bash
# `/libs/db`
npx prisma migrate dev --name MIGRATION_NAME
```

Generate Prisma Client

```bash
# `/libs/db`
npx prisma generate
```
