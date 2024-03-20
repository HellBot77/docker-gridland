FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/doublespeakgames/gridland.git && \
    cd gridland && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG}) && \
    rm -rf .git && \
    for file in www/css/main.css www/js/app/audio/audio.js www/js/app/graphics/sprites.js; do \
        sed -i 's/http:\/\/glmedia\.doublespeakgames\.com//g' ${file}; \
    done

FROM openjdk:15-slim AS build

WORKDIR /gridland
COPY --from=base /git/gridland .
RUN apt update && \
    apt download ant && \
    dpkg --force-all --install ant*.deb && \
    ant build

FROM lipanski/docker-static-website

COPY --from=build /gridland/build .
