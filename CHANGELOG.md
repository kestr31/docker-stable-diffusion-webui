# 1.3.0 (2024-06-23)

> This version is completely incompatible with previous versions due to major changes.
> Please backup your data before updating.

- Based on `nvidia/cuda:12.2.2-runtime-ubuntu22.04`.
    - However, due to following characteristics, more CUDA variants will be provided.
- **Container version is now "decoupled" from the Stable-Diffusion-WebUI version**.
  - The container will only include `apt` dependencied required for the Stable-Diffusion-WebUI.
    - That is, the container will load the Stable-Diffusion-WebUI from the mounted volume on `/home/user/workspace`.
  - Along with the changing base image from `dev` variant of `nvidia/cuda` to `runtime` variant, **the container size is now reduced to about 2.5 GB from about 10 GB**.
- **Added convenience scrips to run / stop / debug the SD-WebUI container.**
  - For example, you now only need to run `./scripts/sd-webui.sh run` to deploy the container.
  - Please refer to the [README.md](./README.md) for more information.

# 1.2.1 (2023-03-27)
- `nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04`.
- Staying at Stable-Diffusion-WebUI commit `a9eab236d7e8afa4d6205127904a385b2c43bb24`.
- Fixed write permission issues on following directories caused by mismatching PID/GID when volume-mappedL
  - `/home/user/stable-diffusion-webui/extensions`
  - `/home/user/stable-diffusion-webui/outputs`
  - `/home/user/stable-diffusion-webui/models`

# 1.2.0 (2023-03-27)

- `nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04`.
- Update to Stable-Diffusion-WebUI commit `a9eab236d7e8afa4d6205127904a385b2c43bb24`.
- Total rework on Dockerfile structure.
  - Mainly to make update to Stable-Diffusion-WebUI's newer commits much easier.
  - Removal of xformers build part since it is provided in pip repository.
- Reworked dependencies. Now they depend more on `requirements.txt` of Stable-Diffusion-WebUI.
- Reworked permission of `user`.
  - Installation process is now all done by `user` in order to shorten docker image build time.
  - `user` can now use sudo command inside a container without authentication.
- Reworked initialization process of Stable-Diffusion-WebUI. Now, only `entrypoint.sh` takes part.
- Modified `docker-compose.yml` to set gradeio authentication using docker secret.
- Modified directory structure of the repository to be more 'ordered'
- [Docker Hub](https://hub.docker.com/layers/kestr3l/stable-diffusion-webui/1.2.0/images/)

# 1.1.1 (2023-01-11)

- `nvidia/cuda:11.7.1-devel-ubuntu22.04`
- Removed redundant blank on env. var. settings on `docker-compose.yml` which might cause an error
- Fixed mismatching directory on `run.sh` since `styles.csv` was moved to `styles/styles.csv`
- [DockerHub](https://hub.docker.com/layers/kestr3l/stable-diffusion-webui/1.1.1/images/sha256-37617664832c4a495765faae143688e74ea45d33240ab195cac7bb345ffbefed?context=explore)

# 1.1.0 (2023-01-18)

- `nvidia/cuda:11.7.1-devel-ubuntu22.04`
- Updated `stable-diffusion-webui` to commit [dac59b9](https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/dac59b9b073f86508d3ec787ff731af2e101fbcc)
- `xformers` is not built separately now. Build and install process is included inside the image.
  - `xformers` commit id: [814314d](https://github.com/facebookresearch/xformers/commit/814314dfc207836839c57613c0354fef6e07fa2d)
- Changed docker volume mapping structure
  - Directories that can be mapped: `models`, `VAE`, `outputs`, `styles`, `extensions`
  - Files that can be mapped: `config.json`, `ui-config.json`, `webui-user.sh`
- Updated [prompt auto-completion javascript](https://greasyfork.org/ko/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1) credited by [shounksu](https://greasyfork.org/ko/users/815641-shounksu)
- Added `LICENSE` based on [AUTOMATIC111's LICENSE](https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/LICENSE.txt)
- [Docker Hub](https://hub.docker.com/layers/kestr3l/stable-diffusion-webui/1.1.1/images/)

# 1.0.2 (20221016)

- `nvidia/cuda:11.3.1-runtime-ubuntu20.04`
- Updated `stable-diffusion-webui` to commit [36a0ba3](https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/36a0ba357ab0742c3c4a28437b68fb29a235afbe)
  - `Added Refresh Button to embedding and hypernetwork names in Train Tab`
- Resolved file permission issues due to different UID & GIDs
  - Now, any volume or file can be mapped to host volume
- Updated [prompt auto-completion javascript](https://greasyfork.org/ko/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1) credited by [shounksu](https://greasyfork.org/ko/users/815641-shounksu)
- [Docker Hub](https://hub.docker.com/layers/kestr3l/stable-diffusion-webui/1.0.1/images/)

# 1.0.1 (20221016)

- `nvidia/cuda:11.3.1-runtime-ubuntu20.04`
- Updated `stable-diffusion-webui` to commit [be1596c](https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/be1596ce30b1ead6998da0c62003003dcce5eb2c)
- Applied xformers [3633e1a](https://github.com/facebookresearch/xformers/commit/3633e1afc7bffbe61957f04e7bb1a742ee910ace)
- Applied modified initial settings as default

# 1.0.0 (20221009)

- `nvidia/cuda:11.3.1-runtime-ubuntu20.04`
- Initial batch