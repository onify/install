Install Onify Hub in Kubernetes
===============================

# Images

To retreive images from the onify registry you need a registry secret. Contact Onify at support@onify.co for this.

* hub/api
* hub/app
* hub/agent-server

# Preparations

1. Get your container [registry credentials](#docker-registry-credentials)
2. Get your Onify license
3. Clone repository (optional)
4. Make sure container manifest labels are unique for your organization

# Deployment pipeline

1. [elasticsearch 7](#elasticsearch) container unless you have your own
2. [Onify registration credentials](#docker-registry-credentials)
2. agent-server container
3. Setup hub-api container and environment variables
4. Setup hub-app container and environment variables
5. Optional [traefik](#traefic) container with external hosts and TLS termination

# Docker registry credentials

Registry credentials, contact Onify at support@onify.co to get your `keyfile.json`.

Run the following command to add your registry secret:

```sh
kubectl create secret docker-registry onify-regcred \
  --docker-server=eu.gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat keyfile.json)" \
  --docker-email=admin@onify.local
```

# Secrets

Secrets are saved in base64 format

- `admin_password`: Your Administrator password. Minimum 8 chars and maximum 100 chars. Requires both uppercase and lowercase letters and must also contain digits and symbols
- `app_token_secret`: Your app token secret
- `client_secret`: Arbitrary secret string used for signing, previously known as private key. If a migration is imminent: use the same secret as the old environment
- `api_token`: [Api token](#api-token) used by app for backend communication

# Environment variables

## Environment variables for hub-api

- `ONIFY_adminUser_password`: from secret `admin_password`
- `ONIFY_adminUser_username`: administrator username, defaults to `admin`
- `ONIFY_apiTokens_app_secret`: from secret `app_token_secret`
- `ONIFY_autoinstall`: autoinstall Elasticsearch indices if they are missin
- `ONIFY_client_code`: Client three letter code, included in license
- `ONIFY_client_instance`: Client instance name, included in license
- `ONIFY_client_secret`: from secret `client_secret`
- `ONIFY_db_elasticsearch_host`: Elastic search host
- `ONIFY_db_indexPrefix`: Index name prefix, usually client code
- `ONIFY_initialLicense`: Optional, generated initial license if any
- `ONIFY_logging_logLevel`: Optional, log level, one of `fatal`, `error`, `warn`, `info`, `debug`, or `trace`, defaults to `warn`
- `ONIFY_resources_baseDir`: Base directory for storing resource files, usually points to mounted folder
- `ONIFY_resources_tempDir`: Base directory for storing temporary files, usually points to mounted folder
- `ONIFY_websockets_agent_url`: Agent server websocket url

## Environment variables for hub-app

* `ONIFY_api_adminToken` - from secret `api_token` used by app for backend communication
* `ONIFY_api_internalUrl` - Internal url for backend connection with API, defaults to `http://api:8181/api/v2`, depends on exposed api service
* `ONIFY_api_externalUrl` - External url for frontend API calls, set to relativeUrl `/api/v2`, or use `api_public_host`
* `ONIFY_logging_logLevel`: Optional, log level, one of `fatal`, `error`, `warn`, `info`, `debug`, or `trace`, defaults to `warn`
* `ONIFY_disableAdminEndpoints`: Optional boolean flag to disable all admin endpoints in hub-app, defaults to false

# Elasticsearch

Onify persistance.

## `elasticsearch.yaml`

Elasticsearch manifest.

Configuration:
- `PersistentVolume`: Should be altered to match kubernetes installation
  - `hostPath.path`:Shared directory between

When applied the container can be tested by:

```sh
kubectl exec -it elasticsearch-0 -- curl http://localhost:9200
```

# Traefik

TLS termination requires certificates, the example manifest is configured to use letsencrypt.

Before installing traefik the following hosts have to be decided.

- `agent-server_host`: host for access to agent server (internal)
- `api_public_host`: host for public access to api
- `app_public_host`: host for public access to app

### Api-token

Token used to authenticate app backend with api. Generated api token from value of `app_token_secret`:

For OSX or Linux
```sh
echo "Bearer $(echo -n "app:<value of app_token_secret>" | base64)"
```

or Windows (Powershell):
```powershell
"Bearer " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("app:<value of app_token_secret>"))
```

Remember to convert the token to base64 before saving it to secret manifest.
