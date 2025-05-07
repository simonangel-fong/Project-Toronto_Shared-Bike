

- Token

```conf
TUNNEL_TOKEN="token"
```

```sh
# cloudflare/
docker compose -f compose.cloudflare.dev.yaml up --build -d

# test
trips.arguswatcher.net

curl -k https://trips.arguswatcher.net/user-segmentation/
```