# dev-env

## Setup secrets
```
> chmod 600 ./secrets
```

### Setup SSH
```
> cd ~/.ssh
> ssh-keygen -t ed25519 -f dev-env
> cd -
> cp ~/.ssh/dev-env.pub ./secrets
```
```
> ssh nxvzbgbfben@localhost -p 2222 -i ~/.ssh/dev-env
```
