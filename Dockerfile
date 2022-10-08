ARG BASEIMAGE
ARG BASETAG

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


FROM ${BASEIMAGE}:${BASETAG} as stage_deps

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY deps/aptdeps.txt /tmp/aptdeps.txt

RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptdeps.txt) \
    && rm -rf /tmp/* \
    && useradd -m user


FROM stage_deps as stage_app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY deps/pydeps.txt /tmp/pydeps.txt

WORKDIR /home/user
USER user

RUN \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git \
    && wget -O \
        /home/user/stable-diffusion-webui/xformers-0.0.14.dev0-cp310-cp310-win_amd64.whl \
        https://github.com/C43H66N12O12S2/stable-diffusion-webui/releases/download/b/xformers-0.0.14.dev0-cp310-cp310-win_amd64.whl \
    && sed -i "s/COMMANDLINE_ARGS=\"\"/COMMANDLINE_ARGS=\"--xformers\"/g" /home/user/stable-diffusion-webui/webui-user.sh \
    && python3 -m venv /home/user/stable-diffusion-webui/venv \
    && source /home/user/stable-diffusion-webui/venv/bin/activate \
    && python3 -m pip install $(cat /tmp/pydeps.txt) \
    && rm -rf /tmp/* \

LABEL title="Stable-Diffusion-Webui-Docker"
LABEL version="1.0"

EXPOSE 7860
ENTRYPOINT [ "/home/user/stable-diffusion-webui/webui.sh" ]

# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.3.1-runtime-ubuntu20.04 \
# -t kestr3l/stable-diffusion-webui:1.0.0 \
# -f Dockerfile .

# docker run -it --rm \
#     -e NVIDIA_DISABLE_REQUIRE=1 \
#     -e NVIDIA_DRIVER_CAPABILITIES=all \
#     -v <DIR_TO_CHECKPOINT>:/home/user/stable-diffusion-webui/models/Stabble-diffusion
#     -p <PORT>:7860 \
#     --gpus all \
#     --privileged \
#     kestr3l/stable-diffusion-webui:1.0.0