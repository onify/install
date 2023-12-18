# Install Onify on Docker

> Note: This documentation is mainly to get a development environment up and running. If you want to run Onify on Docker in prod, you need to setup nginx etc. 

## Prerequisites

### Docker

You need to have Docker installed, like [Docker Swarm](https://docs.docker.com/get-started/swarm-deploy/) or [Docker Desktop](https://www.docker.com/products/docker-desktop/). 

### Access to container images

You need access to the Onify Hub container images located at Google Container Registry (`eu.gcr.io`). For this you need a `keyfile.json`. Please contact `support@onify.co` for more info.

Login to Docker with:

For OSX or Linux
```sh
cat keyfile.json | docker login -u _json_key --password-stdin https://eu.gcr.io/onify-images
```

or Windows (cmd)
```sh
docker login -u _json_key --password-stdin https://eu.gcr.io/onify-images < keyfile.json
```

> Note: You might also need access to GitHub Container Registry (`ghcr.io`). You need a username and a personal access token (PAT) for this.

## Installation

1. Create a `.env` file (see `.env.example`) containing all environment variables
2. Check that you have the environments in place by calling `docker-compose config` (optional)
3. Start Onify Hub by calling `docker-compose up`

### API TOKEN

Token used to authenticate app backend with api. Generated api token from `API_APP_SECRET`:

For OSX or Linux
```sh
source .env
echo "Bearer $(echo -n "app:$API_APP_SECRET" | base64)"
```

or Windows (Powershell):
```powershell
$API_APP_SECRET="<Onify hub app secret>"
"Bearer " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("app:" + $API_APP_SECRET))
```

Add the result as `APP_API_TOKEN` value in `.env` file where the value is surrounded by quotes.

## Troubleshooting

### Testing app and api

Hub is exposed as:

- `app`: http://localhost:3000
  - try to login with admin and your `ADMIN_PASSWORD` set in `.env` file
- `api`: http://localhost:8181/documentation

or start things with names using `-d` to detach the container from the console.

```sh
docker-compose up -d elasticsearch agent-server
docker-compose up api worker app
```

### Reset everything

To reset the entire Hub you can delete the Elasticsearch indices.

```sh
curl -XDELETE http://localhost:9200/*
```

The api will crash and restart and you are back to square 1.