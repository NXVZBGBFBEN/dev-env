FROM ghcr.io/nxvzbgbfben/dev-env/main:latest

RUN --mount=type=secret,id=ssh_docker,uid=1000,required \
    mkdir -m 700 -p /home/nxvzbgbfben/.ssh && cat /run/secrets/ssh_docker >> /home/nxvzbgbfben/.ssh/authorized_keys
