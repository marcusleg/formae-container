# Formae Container

> [!IMPORTANT]
> This repository is archived.  
> Platform Engineering Labs now provides an official container
> image: https://github.com/platform-engineering-labs/formae/pkgs/container/formae

A container for the [Formae](https://github.com/platform-engineering-labs/formae) agent.

## Run locally

```bash
podman build -t formae-agent .
podman run -it -p 49684:49684 formae-agent
```

## Deploy to AWS App Runner (WIP)

```bash
build-and-push-to-ecr.sh
create-app-runner-service.sh
```
