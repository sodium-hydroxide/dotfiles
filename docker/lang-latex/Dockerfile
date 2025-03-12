FROM alpine:3.21.3
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/main/" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/community/" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk update && apk add \
    texlive \
    pandoc \
    uv \
    R-dev \
    && apk cache clean

RUN adduser -D user
WORKDIR /home/user
USER user
CMD [ "sh" ]
