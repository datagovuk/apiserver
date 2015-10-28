[![Build Status](https://semaphoreci.com/api/v1/projects/0b4849a6-8e75-4040-9855-3747f08b7376/584694/badge.svg)](https://semaphoreci.com/ross/apiserver)

# ApiServer

To start the server

  1. Install dependencies with `mix deps.get`
  2. export DGU_ETL_CONFIG="/path/to/apiserver/dgu-api-etl/config.ini"
  3. For those themes that have them generate the distinct lookups with ```mix distinct.generate transport.anonymised_mot_tests```
  4. Start server with MIX_ENV=dev mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Environment variables

The table below documents the environment variables used/interpreted by the api server.

| Environment Var | Description | Example | Default |
|----------|-----------|-----------|-----------|
|  DGU_ETL_CONFIG | Location of ETL .ini file | /etc/apiserver/config.ini | None |
| MIX_ENV  | Which version of app to run  |  DEV, TEST, PROD  | DEV  |
| PGPORT | Port on which Postgres is listening  | 5432  | 5432  |



