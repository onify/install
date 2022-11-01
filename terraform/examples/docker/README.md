Install Onify Hub in Docker
===========================

Use docker compose to run your hub.

# Images

To retreive images from the onify registry you need a registry secret. Contact Onify at support@onify.co for this.

* hub/api
* hub/app
* hub/agent-server

# Preparations

Some preparations is required to run in docker.

## Image registry secret

Onify images are stored in a registry that requires authentication to access.

Request your image registry secret from support@onify.co and save as `keyfile.json` in this directory

Login to docker with:

For OSX or Linux
```sh
cat keyfile.json | docker login -u _json_key --password-stdin https://eu.gcr.io/onify-images
```

or Windows (cmd)
```sh
docker login -u _json_key --password-stdin https://eu.gcr.io/onify-images < keyfile.json
```

## Env file

Add a file named `.env` in the same directory. Prepare the file with environment variables required for the docker compose manifest:

```
ADMIN_PASSWORD=<administrator password>
APP_API_TOKEN=
API_APP_SECRET=<Onify hub app secret>
API_CLIENT_SECRET=<sign secret>
API_CLIENT_CODE=
API_CLIENT_INSTANCE=
LICENSE=
```

- `ADMIN_PASSWORD`: administrator password. Minimum 8 chars and maximum 100 chars. Requires both uppercase and lowercase letters and must also contain digits and symbols
- `API_CLIENT_SECRET`: secret string used for signing, previously known as private key. If a migration is imminent: use the same secret as the old environment
- `API_APP_SECRET`: hub app application secret for the api, generate your own very secret key
- `APP_API_TOKEN`: [Api token](#api-token) used by app for backend communication
- `API_CLIENT_CODE`: Client code, decided by Onify when generating license
- `API_CLIENT_INSTANCE`:  Client instance (or purpose), decided by Onify when generating license
- `LICENSE`: [Onify license](#onify-license)

### Api-token

Token used to authenticate app backend with api. Generated api token from `API_APP_SECRET`:

For OSX or Linux
```sh
source .env
echo "Bearer $(echo -n "app:$API_APP_SECRET" | base64)"
```

or Windows (Powershell):
```powershell
$API_APP_SECRET=<Onify hub app secret>
"Bearer " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("app:" + $API_APP_SECRET))
```

Add the result as `APP_API_TOKEN` value in `.env` file where the value is surrounded by quotes.

### Onify License

Get your Onify docker license key, client code, and client instance from support@onify.co and add them as values for `LICENSE`, `API_CLIENT_CODE`, and `API_CLIENT_INSTANCE` the `.env` file.

```
ADMIN_PASSWORD=<administrator password>
API_APP_SECRET=<Onify hub app secret>
APP_API_TOKEN="<Onify hub app api token>"
API_CLIENT_SECRET=<sign secret>
API_CLIENT_CODE=<Client code from Onify>
API_CLIENT_INSTANCE=<Client instance from Onify>
LICENSE=<Onify license>
```

# Start Onify Hub in docker

Check that you have the environments in place by calling:

```sh
docker-compose config
```

Start the hub by calling:

```sh
docker-compose up
```

Hub is exposed as:

- `app`: http://localhost:3000
  - try to login with admin and your `ADMIN_PASSWORD` set in `.env` file
- `api`: http://localhost:8181/documentation

or start things with names using `-d` to detach the container from the console.

```sh
docker-compose up -d elasticsearch agent-server
docker-compose up api worker app
```

Pull new images by:

```sh
docker-compose pull
```

# Reset Hub

To reset the entire hub you can delete the indices.

```sh
curl -XDELETE http://localhost:9200/*
```

The api will crash and restart and you are back to square 1.

