# ApiServer

To start the server

  1. Install dependencies with `mix deps.get`
  2. export DGU_ETL_CONFIG="/path/to/apiserver/dgu-api-etl/config.ini"
  3. Start Phoenix endpoint with `HOST="localhost:4000" MIX_ENV=dev mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Environment variables

The table below documents the environment variables used/interpreted by the api server.

| Environment Var | Description | Example | Default |
|----------|-----------|-----------|-----------|
|  DGU_ETL_CONFIG | Location of ETL .ini file | /etc/apiserver/config.ini | None |
| HOST | Host name for server | "localhost:4000", "api.data.gov.uk" |  localhost |
| MIX_ENV  | Which version of app to run  |  DEV, TEST, PROD  | DEV  |
| PGPORT | Port on which Postgres is listening  | 5432  | 5432  |



