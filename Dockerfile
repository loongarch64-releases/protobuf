FROM lcr.loongnix.cn/library/debian:unstable

RUN apt update && apt install -y git \
    golang \
    make \
    libseccomp-dev \
    zip \
    build-essential \
    cmake

ENV PROTOBUF_VERSION=''

CMD ["sh", "-c","/workspace/process_version.sh $PROTOBUF_VERSION"]
