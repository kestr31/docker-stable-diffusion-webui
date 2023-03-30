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

COPY deps/aptDeps.txt /tmp/aptDeps.txt

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

# SWITCH TO THE GENERATED USER
WORKDIR /home/user
USER user

# CLONE AND PREPARE FOR THE SETUP OF KOHYA_SS GUI
RUN \
    git clone https://github.com/bmaltais/kohya_ss.git \
    # CHECKOUT TO COMMIT acf7d4785f79d858fb1660ae28456d2865f97af6
    && git -C /home/user/kohya_ss reset --hard acf7d4 \
    && sed -i "/python3-tk/d" /home/user/kohya_ss/ubuntu_setup.sh \
    && sed -i "/accelerate config/d" /home/user/kohya_ss/ubuntu_setup.sh \
    && sed -i '/torch==/c\pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 --extra-index-url https://download.pytorch.org/whl/cu117' /home/user/kohya_ss/ubuntu_setup.sh \
    && sed -i '/xformers/c\pip install xformers==0.0.16' /home/user/kohya_ss/ubuntu_setup.sh

# GENERATE DIRECTORIED USED FOR DOCKER VOLUME MOUNT
RUN \
    mkdir /home/user/kohya_ss/images \
    && mkdir /home/user/kohya_ss/logs \
    && mkdir /home/user/kohya_ss/models \
    && mkdir /home/user/kohya_ss/regularizations

# COPY PRESET ACCELERATE SETTINGS FILE
COPY \
    --chmod=644 \
    --chown=user:user \
    settings/default_config.yaml /home/user/.cache/huggingface/accelerate/default_config.yaml

# SET INITIAL DIRECTORY
WORKDIR /home/user/kohya_ss

# INSTALL DEPENDENCIES FOR KOHYA_SS GUI
RUN \
    python3 -m venv /home/user/kohya_ss/venv \
    && source /home/user/kohya_ss/venv/bin/activate \
    && /home/user/kohya_ss/ubuntu_setup.sh

# COPY entrypoint.sh
COPY --chmod=775 scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

USER root

# PORT AND ENTRYPOINT, USER SETTINGS
EXPOSE 7860 7861
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# DOCKER IAMGE LABELING
LABEL title="Kohya_SS-GUI-Docker"
LABEL version="1.0.0-acf7d4"

# ---------- BUILD COMMAND ----------
# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.7.1-cudnn8-devel-ubuntu22.04 \
# -t kestr3l/kohya-ss-gui:1.0.0-acf7d4 \
# -f Dockerfile .