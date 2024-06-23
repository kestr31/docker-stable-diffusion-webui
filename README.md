# Stable-Diffusion-Webui-Docker
- Dockerized Stable-Diffusion-Webui based on [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- Image is based on nvidia/cuda:12.2.2-runtime-ubuntu22.04 
- Prebuilt images are available on Docker Hub:
  - [kestr3l/stable-diffusion-webui](https://hub.docker.com/r/kestr3l/stable-diffusion-webui)

## 0 Prequisites

- Linux environment (Including WSL2)
- 'Appropriate' GPU
- [docker-ce](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
- [docker compose](https://docs.docker.com/compose/install/) (Will be installed with `docker-ce`)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- Basic knowledges of Linux commands

## 1 Building and Running `docker-stable-diffusion-webui` Docker Image

### 1.1 Building the Docker Image

- Use convenience script `build.sh` to build your own image.

```bash
./scripts/build.sh <IMAGE_NAME> <CUDA_VERSION>
# Example: ./scripts/build.sh kestr3l/stable-diffusion-webui 12.2.2
# This will build "kestr3l/stable-diffusion-webui:1.3.0-12.2.2"
```

> The variable "${REPO_VERSION}" is hardcoded in the script.

### 1.2 Running `docker-stable-diffusion-webui` Container

- Run `sd-webui.sh` to deploy the container
- By default, the script will make a workspace directory at `${HOME}/Documents/sd-webui`.
    - Then, the script will copy `compose.yml` and `run.env` to the workspace.
    - Values that need to be changed will be modified automatically.
    - Lastly, the script will clone the `stable-diffusion-webui` repository to the workspace and run the container.

```bash
./scripts/sd-webui.sh run <WORKSPACE_DIR (Optional)>
# Example: ./scripts/sd-webui.sh run
# This will create a workspace at ${HOME}/Documents/sd-webui
# and copy/clone necessary files to the workspace.
```

- After running the script, you can access the webui at `http://localhost:8000`.
    - By default `--listen` argument is set. Please be aware of the security issues.
    - I strongly recommend to block port or set password as soon as possible.

> The container name will be default to `sd-webui`. This value is hardcoded in `run.env`. CUDA version and sd-webui version to use are also hardcoded in `run.env`.

### 1.3. Stop `docker-stable-diffusion-webui` Docker Container

- Run `sd-webui.sh` with `stop` argument to stop the container.

```bash
./scripts/sd-webui.sh stop
```

### 1.4. Debugging `stable-diffusion-webui` Docker Image

- Run `sd-webui.sh` with `debug` argument to run the container in debug mode.
- The entrypoint will be overridden with `sleep infinity` so that you can access the container for debugging.

```bash
./scripts/sd-webui.sh debug
# You can access the container by running:
# docker exec -it sd-webui /bin/bash
```

## 2. Customizing `stable-diffusion-webui`

### 2.1. Changing the Access Port

- The port can be changed by modifying `run.env` file.

```bash
...
WEBUI_PORT=7860
```

### 2.2. Adding additional arguments to `stable-diffusion-webui`

- Resources of `stable-diffusion-webui` if located at `${HOME}/Documents/sd-webui/stable-diffusion-webui` by default.
    - It may vary based on your workspace setting.
- You can add additional arguments to `stable-diffusion-webui` by modifying `webui-user.sh` file.
    - By default, `--listen --enable-insecure-extension-access` is set.
    - Check the [official documentation](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Command-Line-Arguments-and-Settings) for more information.

```bash
...
export COMMANDLINE_ARGS="--gradio-auth yourAccount:yourPass --xformers"
...
```

## 2 Future Plans

- CI/CD for automated image update
- Image for training environment

## 3 References

1. [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)