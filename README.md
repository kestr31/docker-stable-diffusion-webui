# Stable-Diffusion-Webui-Docker
- Dockerized Stable-Diffusion-Webui based on [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- Applied prebuilt [facebookreseasrch/xformers](https://github.com/facebookresearch/xformers)
- Includes [prompt auto-completion javascript](https://greasyfork.org/ko/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1) credited by [shounksu](https://greasyfork.org/ko/users/815641-shounksu)
- Image is based on nvidia/cuda:11.3.1-devel-ubuntu20.04 image

## 0 Prequisites

- 'Appropriate' GPU
- [docker-ce](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- Basic knowledges of Linux commands

## 1 stable-diffusion-webui

### 1.1 Building `stable-diffusion-webui` Docker Image

```shell
DOCKER_BUILDKIT=1 docker build --no-cache \
--build-arg BASEIMAGE=nvidia/cuda \
--build-arg BASETAG=11.3.1-devel-ubuntu20.04 \
-t kestr3l/stable-diffusion-webui:1.0.0 \
-f Dockerfile .
```

### 1.2 Running `docker-stable-diffusion-webui` Container

- Basic docker CLI command of running a container is suggested as below
- You need to prepare a model on your own since I can't provide it
- Based on your need, set your own port to connect
  - Instead of setting a port, you can use `--net host` which makes container to use host network adapter

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
- If you want to save `ui-config.json`, `config.json`, `styles.csv` regardless of container state, map:
  - `-v /dir/to/ui-config.json:/home/user/stable-diffusion-webui/ui-config.json`
  - `-v /dir/to/config.json:/home/user/stable-diffusion-webui/config.json`
  - `-v /dir/to/styles.csv:/home/user/stable-diffusion-webui/styles.csv`

### 1.3 Debugging `stable-diffusion-webui` Docker Image

- Comment-out all lines except `sleep infinity` in `entrypoint.sh`
- Then volume-mount modified `entrypoint.sh` when generaeting debug container

```shell
docker run -it --rm \                                                                                              -e NVIDIA_DISABLE_REQUIRE=1 \
    -e NVIDIA_DRIVER_CAPABILITIES=all \                                                                            -v <DIR_TO_CHECKPOINT>:/home/user/stable-diffusion-webui/models/Stabble-diffusioni
    -v <DIR_TO_ENTRYPOINT.SH>:/usr/local/bin/entrypoint.sh
    -p <PORT>:7860 \
    --name stable-diffusion-webui-dbg \
    --gpus all \                                                                                                   --privileged \                                                                                                 kestr3l/stable-diffusion-webui:1.0.1
```

- Then enter the container by `docker exec -it stable-diffusion-webui-dbg bash'
- If you need a root previlege, use `docker exec -it --user root stable-diffusion-webui-dbg bash'

## 2 xformers-builder (Optional)

> Build process of `xformers` is referenced from [리눅스 xformers 빌드 방법 (GPU 불필요) (작성 중)](https://arca.live/b/aiart/6066407)

### 2.1 Build `xformers-builder` Docker Image

```shell
DOCKER_BUILDKIT=1 docker build --no-cache \
--build-arg BASEIMAGE=nvidia/cuda \
--build-arg BASETAG=11.3.1-devel-ubuntu20.04 \
-t kestr3l/xformer-builder:cu113-1.0.0 \
-f Dockerfile .
```

### 2.2 Build xfomers using `xformers-builder` Container

- Clone [facebookresearch/xformers](https://github.com/facebookresearch/xformers) and update submodules
  - `git submodule update --init --recursive`
- Then mount xformers directory into docker container. Set `MAX_JOBS` based on your need

```
docker run -it --rm \
     -e NVIDIA_DISABLE_REQUIRE=1 \
     -e NVIDIA_DRIVER_CAPABILITIES=all \
     -e MAX_JOBS=$(nproc) \
     -v /dir/to/xformers/repo:/root/xformers \
     --gpus all \
     --privileged \
     kestr3l/xformer-builder:cu113-1.0.0
```

- `.whl` file will be generated on `xforemrs/dist` directory

> An image and an entrypoint is based on CUDA 11.3
> You can modify it based on your need and for use in custom environment

## 3 References

1. [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
2. [facebookreseasrch/xformers](https://github.com/facebookresearch/xformers)
3. [WebUI 태그 자동완성](https://greasyfork.org/ko/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1)
4. [리눅스 xformers 빌드 방법 (GPU 불필요) (작성 중)](https://arca.live/b/aiart/60664075) 
