ARG BASEIMAGE
ARG BASETAG

# STAGE FOR CACHING APT PACKAGE LIST
FROM ${BASEIMAGE}:${BASETAG} as stage_apt

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN \
    rm -rf /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
	&& apt-get update

# STAGE FOR INSTALLING APT DEPENDENCIES
FROM ${BASEIMAGE}:${BASETAG} as stage_deps

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY aptDeps.txt /tmp/aptDeps.txt

# INSTALL APT DEPENDENCIES USING CACHE OF stage_apt
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptDeps.txt) \
    && rm -rf /tmp/*

# ADD NON-ROOT USER user FOR RUNNING THE WEBUI
RUN \
    groupadd user \
    && useradd -ms /bin/bash user -g user \
    && echo "user ALL=NOPASSWD: ALL" >> /etc/sudoers


# STAGE FOR BUILDING APPLICATION CONTAINER
FROM stage_deps as stage_app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG SD_WEBUI_VERSION

ENV \
    DEBIAN_FRONTEND=noninteractive \
    FORCE_CUDA=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH \
    NVCC_FLAGS="--use_fast_math -DXFORMERS_MEM_EFF_ATTENTION_DISABLE_BACKWARD"\
    PATH=/usr/local/cuda-11.7/bin:$PATH \
    TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6"

# SWITCH TO THE GENERATED USER
WORKDIR /home/user
USER user

# CLONE AND PREPARE FOR THE SETUP OF SD-WEBUI
RUN \ 
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git -b ${SD_WEBUI_VERSION:-v1.6.0}
WORKDIR /home/user/stable-diffusion-webui

RUN \
    mkdir /home/user/stable-diffusion-webui/outputs \
    && mkdir /home/user/stable-diffusion-webui/styles

# RUN \
#     wget -O \
#         /home/user/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors \
#         https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors \
#     && ./webui.sh --xformers --skip-torch-cuda-test --no-download-sd-model --exit

RUN \
    ./webui.sh --xformers --skip-torch-cuda-test --no-download-sd-model --exit

# INCLUDE AUTO COMPLETION JAVASCRIPT
RUN \
    curl -o /home/user/stable-diffusion-webui/javascript/auto_completion.js \
        https://greasyfork.org/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1/code/WebUI%20%ED%83%9C%EA%B7%B8%20%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1.user.js

# COPY entrypoint.sh
COPY --chmod=775 scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
USER root

# PORT AND ENTRYPOINT, USER SETTINGS
EXPOSE 7860
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# DOCKER IAMGE LABELING
LABEL title="Stable-Diffusion-Webui-Docker"
LABEL version=${SD_WEBUI_VERSION:-v1.6.0}

# ---------- BUILD COMMAND ----------
# DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain \
# SD_WEBUI_VERSION=v1.6.0 && \
#  docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.7.1-cudnn8-devel-ubuntu22.04 \
# --build-arg SD_WEBUI_VERSION=${SD_WEBUI_VERSION} \
# -t kestr3l/stable-diffusion-webui:${SD_WEBUI_VERSION} \
# -f Dockerfile .