# Stable-Diffusion-Webui-Docker
- Dockerized Stable-Diffusion-Webui based on [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)

## Build

```shell
DOCKER_BUILDKIT=1 docker build --no-cache \
--build-arg BASEIMAGE=nvidia/cuda \
--build-arg BASETAG=11.3.1-runtime-ubuntu20.04 \
-t kestr3l/stable-diffusion-webui:1.0.0 \
-f Dockerfile .
```

## Run

```shell
docker run -it --rm \
    -e NVIDIA_DISABLE_REQUIRE=1 \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    -v <DIR_TO_CHECKPOINT>:/home/user/stable-diffusion-webui/models/Stabble-diffusion
    -p <PORT>:7860 \
    --gpus all \
    --privileged \
    kestr3l/stable-diffusion-webui:1.0.0
```

- Then connect to `http://localhost:7860` or `http://<private_ip>:7860`