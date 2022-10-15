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

WORKDIR /root

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    FORCE_CUDA=1 \
    TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6" \
    XFORMERS_DISABLE_FLASH_ATTN=1 \
    NVCC_FLAGS="--use_fast_math -DXFORMERS_MEM_EFF_ATTENTION_DISABLE_BACKWARD"

COPY deps/aptdeps.txt /tmp/aptdeps.txt
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptdeps.txt) \
    && rm -rf /tmp/*

LABEL title="docker-xformer-builder"
LABEL version="cu113-1.0.0"

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.3.1-devel-ubuntu20.04 \
# -t kestr3l/xformer-builder:cu113-1.0.0 \
# -f Dockerfile .

# docker run -it --rm \
#     -e NVIDIA_DISABLE_REQUIRE=1 \
#     -e NVIDIA_DRIVER_CAPABILITIES=all \
#     -e MAX_JOBS=$(nproc) \
#     -v /dir/to/xformers/repo:/root/xformers
#     --gpus all \
#     --privileged \
#     kestr3l/xformer-builder:cu113-1.0.0
