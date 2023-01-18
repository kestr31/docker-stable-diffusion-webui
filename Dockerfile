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

COPY deps/aptdeps.txt /tmp/aptdeps.txt

# INSTALL APT DEPENDENCIES USING CACHE OF stage_apt
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptdeps.txt) \
    && rm -rf /tmp/*

# ADD NON-ROOT USER user FOR RUNNING THE WEBUI
RUN \
    groupadd user \
    && useradd -ms /bin/bash user -g user


# STAGE FOR BUILDING APPLICATION CONTAINER
FROM stage_deps as stage_app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    FORCE_CUDA=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH \
    NVCC_FLAGS="--use_fast_math -DXFORMERS_MEM_EFF_ATTENTION_DISABLE_BACKWARD"\
    PATH=/usr/local/cuda-11.7/bin:$PATH \
    TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6" \
    XFORMERS_DISABLE_FLASH_ATTN=1

# COPY FILES REQUIRED FOR THE SETUP
COPY --chown=user:user deps/pydeps.txt /home/user/tmp/pydeps.txt
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /home/user

# SETUP STABLE-DIFFUSION-WEBUI
RUN \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git \
    # SET TO COMMIT ID dac59b9b073f86508d3ec787ff731af2e101fbcc
    && git -C /home/user/stable-diffusion-webui reset --hard dac59b9 \
    && mkdir /home/user/stable-diffusion-webui/styles \
    # INSTALL AUTO COMPLETION JAVASCRIPT
    && curl -o /home/user/stable-diffusion-webui/javascript/auto_completion.js \
        https://greasyfork.org/scripts/452929-webui-%ED%83%9C%EA%B7%B8-%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1/code/WebUI%20%ED%83%9C%EA%B7%B8%20%EC%9E%90%EB%8F%99%EC%99%84%EC%84%B1.user.js \
    && python3 -m venv /home/user/stable-diffusion-webui/venv \
    && source /home/user/stable-diffusion-webui/venv/bin/activate \
    && python3 -m pip install $(cat /home/user/tmp/pydeps.txt) \
    && chmod +x /home/user/stable-diffusion-webui/webui-user.sh \
    && rm -rf /home/user/tmp

# SETUP XFORMERS
RUN \
    mkdir /home/user/stable-diffusion-webui/repositories \
    && git clone https://github.com/facebookresearch/xformers.git \
        /home/user/stable-diffusion-webui/repositories/xformers \
    # SET TO COMMIT ID 814314dfc207836839c57613c0354fef6e07fa2d
    && git -C /home/user/stable-diffusion-webui/repositories/xformers \
        reset --hard 814314d \
    # UPDATE SUBMODULES REQUIRED FOR XFORMERS
    && git -C /home/user/stable-diffusion-webui/repositories/xformers \
        submodule update --init --recursive \
    && source /home/user/stable-diffusion-webui/venv/bin/activate \
    && pip install -r /home/user/stable-diffusion-webui/repositories/xformers/requirements.txt \
    && pip install -e /home/user/stable-diffusion-webui/repositories/xformers

# COPY INITIAL SETTINGS FILES
# THIS KINDA WORK AS A PLACEHOLDER FOR DOCKER VOLUME MOUNT
COPY settings/run.sh /home/user/stable-diffusion-webui/run.sh
COPY settings/config.json /home/user/stable-diffusion-webui/config.json
COPY settings/ui-config.json /home/user/ui-config.json.bak

# CHENGE OWNERSHIP OF ALL FILES AS user:user
RUN \
    chown -R user:user /home/user

# PORT AND ENTRYPOINT, USER SETTINGS
EXPOSE 7860
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# DOCKER IAMGE LABELING
LABEL title="Stable-Diffusion-Webui-Docker"
LABEL version="1.1.0"

# ---------- BUILD COMMAND ----------
# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.7.1-devel-ubuntu22.04 \
# -t kestr3l/stable-diffusion-webui:1.1.0 \
# -f Dockerfile .

# ----------- RUN COMMAND -----------
# docker run -it --rm \
#     --name stable-diffusion-webui \
#     -e NVIDIA_DISABLE_REQUIRE=1 \
#     -e NVIDIA_DRIVER_CAPABILITIES=all \
#     -e UID=$(id -u) \
#     -e GID=$(id -g) \
#     -v <YOUR_DIRECTORY_TO_MODELS>:/home/user/stable-diffusion-webui/models/Stable-diffusion
#     -v <YOUR_DIRECTORY_TO_OUTPUT>:/home/user/stable-diffusion-webui/outputs
#     -v <YOUR_DIRECTORY_TO_STYLES>:/home/user/stable-diffusion-webui/styles
#     -v <YOUR_DIRECTORY_TO_EXTENSIONS>:/home/user/stable-diffusion-webui/models/extensions
#     -v <YOUR_DIRECTORY_TO_VAE>:/home/user/stable-diffusion-webui/models/VAE
#     -v <YOUR_DIRECTORY_TO_config.json>:/home/user/stable-diffusion-webui/config.json
#     -v <YOUR_DIRECTORY_TO_ui-config.json>:/home/user/ui-config.json.bak
#     -v <YOUR_DIRECTORY_TO_webui-user.sh>:/home/user/stable-diffusion-webui/webui-user.sh
#     -p <YOUR_PREFFERED_PORT>:7860 \
#     --gpus all \
#     --privileged \
#     kestr3l/stable-diffusion-webui:1.1.0

# ---------- DEBUG COMMAND ----------
# docker run -it --rm \
#     --name stable-diffusion-webui \
#     -e NVIDIA_DISABLE_REQUIRE=1 \
#     -e NVIDIA_DRIVER_CAPABILITIES=all \
#     -e UID=$(id -u) \
#     -e GID=$(id -g) \
#     ....
#     -v <YOUR_DIRECTORY_TO_entrypoint-debug.sh>:/usr/local/bin/entrypoint.sh
#     -p <YOUR_PREFFERED_PORT>:7860 \
#     --gpus all \
#     --privileged \
#     kestr3l/stable-diffusion-webui:1.1.0