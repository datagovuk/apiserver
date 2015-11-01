[![Build Status](https://semaphoreci.com/api/v1/projects/0b4849a6-8e75-4040-9855-3747f08b7376/584694/badge.svg)](https://semaphoreci.com/ross/apiserver)

# ApiServer

To start the server

  1. Install dependencies with `mix deps.get`
  2. export MANIFESTS="/path/to/manifests"
  3. export DBUSER="reader"
  4. export DBPASS="reader"
  5. For those themes that have them generate the distinct lookups with ```mix distinct.generate transport.anonymised_mot_tests```
  6. Start server with MIX_ENV=dev mix phoenix.server`

To run tests, you need to make sure your manifests are not picked up by running

```
    MANIFEST=/tmp mix test 
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Environment variables

The table below documents the environment variables used/interpreted by the api server.

| Environment Var | Description | Example | Default |
|----------|-----------|-----------|-----------|
| MANIFESTS | Location of folder containing theme and manifests folders | /var/lib/apiserver/ | None |
| MIX_ENV  | Which version of app to run  |  DEV, TEST, PROD  | DEV  |
| PGPORT | Port on which Postgres is listening  | 5432  | 5432  |
| DBUSER | Username for reading from database  | reader  |   |
| DBPASS | Password for user reading from database  | reader  |   |



