# Stable-Diffusion-Webui-Docker
- Dockerized Stable-Diffusion-Webui based on [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- Includes [prompt auto-completion javascript](https://greasyfork.org/ko/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1) credited by [shounksu](https://greasyfork.org/ko/users/815641-shounksu)
- Image is based on nvidia/cuda:11.7.1-devel-ubuntu22.04 image
- Prebuilt images are available on Docker Hub:
  - [kestr3l/stable-diffusion-webui](https://hub.docker.com/r/kestr3l/stable-diffusion-webui)

## 0 Prequisites

- Linux environment (Including WSL2)
- 'Appropriate' GPU
- [docker-ce](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
- [docker-compose](https://docs.docker.com/compose/install/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- Basic knowledges of Linux commands

## 1 stable-diffusion-webui

### 1.1 Building `stable-diffusion-webui` Docker Image

```shell
DOCKER_BUILDKIT=1 \
SD_WEBUI_VERSION=v1.6.0 && \
 docker build --no-cache \
--build-arg BASEIMAGE=nvidia/cuda \
--build-arg BASETAG=11.7.1-cudnn8-devel-ubuntu22.04 \
--build-arg SD_WEBUI_VERSION=${SD_WEBUI_VERSION} \
-t kestr3l/stable-diffusion-webui:${SD_WEBUI_VERSION} \
-f Dockerfile .
```

### 1.2 Running `docker-stable-diffusion-webui` Container

- Simply execute `setup.sh`.
- On the first run, it will create data directory for the WebUI on `Documents` directory and exit.
  - Run it again after then.
- If you want to run this on background, run by `nohup ./setup.sh &`

### 1.3 Debugging `stable-diffusion-webui` Docker Image

- Set `DEBUG_MODE=1` on `run.env`
- This will make container do 'nothing'. So that user can try anything manually
- You can enter a container by `docker exec -it --user user stable-diffusion-webui bash`
- On default, `sudo` is available for the `user`.

## 2 Future Plans

- CI/CD for automated image update
- Image for training environment

## 3 References

1. [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
2. [facebookreseasrch/xformers](https://github.com/facebookresearch/xformers)
3. [WebUI 태그 자동완성](https://greasyfork.org/ko/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1)
4. [리눅스 xformers 빌드 방법 (GPU 불필요) (작성 중)](https://arca.live/b/aiart/60664075) 
5. [Is it possible to map a user inside the docker container to an outside user?](https://stackoverflow.com/questions/57776452/is-it-possible-to-map-a-user-inside-the-docker-container-to-an-outside-user)