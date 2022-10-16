# 1.0.0 (20221009)

- `nvidia/cuda:11.3.1-runtime-ubuntu20.04`
- Initial batch

# 1.0.1 (20221016)

- `nvidia/cuda:11.3.1-runtime-ubuntu20.04`
- Updated `stable-diffusion-webui` to commit [be1596c](https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/be1596ce30b1ead6998da0c62003003dcce5eb2c)
- Applied xformers [3633e1a](https://github.com/facebookresearch/xformers/commit/3633e1afc7bffbe61957f04e7bb1a742ee910ace)
- Applied modified initial settings as default

# 1.0.2 (20221016)

- `nvidia/cuda:11.3.1-runtime-ubuntu20.04`
- Updated `stable-diffusion-webui` to commit [36a0ba3](https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/36a0ba357ab0742c3c4a28437b68fb29a235afbe)
  - `Added Refresh Button to embedding and hypernetwork names in Train Tab`
- Resolved file permission issues due to different UID & GIDs
  - Now, any volume or file can be mapped to host volume
- Updated [prompt auto-completion javascript](https://greasyfork.org/ko/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1) credited by [shounksu](https://greasyfork.org/ko/users/815641-shounksu)
- [Docker Hub](https://hub.docker.com/layers/kestr3l/stable-diffusion-webui/1.0.1/images/