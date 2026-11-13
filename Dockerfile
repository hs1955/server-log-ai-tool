# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.12.3
FROM python:${PYTHON_VERSION}-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Non-privileged user (shared by all stages)
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Install production dependencies (shared by all stages)
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt

# ---- Development stage ----
FROM base AS development

# Install dev tools on top of prod deps (pytest, ruff, debugpy)
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements-dev.txt,target=requirements-dev.txt \
    python -m pip install -r requirements-dev.txt

# Stay as root in dev so tools can write to /app (bind mount is owned by you).
# Production drops to appuser below.
COPY . .

CMD ["python", "-m", "app.main"]

# ---- Production stage ----
FROM base AS production

USER appuser
COPY --chown=appuser:appuser . .

EXPOSE 8000
CMD ["python", "-m", "app.main"]