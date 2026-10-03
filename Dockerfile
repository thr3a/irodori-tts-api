ARG BASE_IMAGE=python:3.14-slim
FROM ${BASE_IMAGE}
ARG IRODORI_TTS_BACKEND=cu128

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/app/.venv

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        ffmpeg \
        git \
        libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

RUN git clone --depth 1 https://github.com/Aratako/Irodori-TTS-Server.git .

RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv sync --locked --no-dev --no-install-project --extra "${IRODORI_TTS_BACKEND}"

RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv sync --locked --no-dev --no-editable --extra "${IRODORI_TTS_BACKEND}"

EXPOSE 8088

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=on
ENV PYTHONDONTWRITEBYTECODE=1

CMD ["/app/.venv/bin/python", "-m", "irodori_openai_tts"]
