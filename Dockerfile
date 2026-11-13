# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.12.3
FROM python:${PYTHON_VERSION}-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# Ensure that the .venv `uv` builds and uses is not in app,
# which could get overwritten by our own local .venv after uv builds it
# with a bad COPY . .
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
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

# ---- Development stage ----
FROM base AS development

# Install uv from its official distroless image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy only dependency files for optimal layer caching
COPY pyproject.toml uv.lock ./

# Install all dependencies, including the dev group
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

# Copy the rest of the application source
COPY . .

# Use `uv run` to execute within the managed environment.
# `uv run` automatically runs `uv sync` and updates `uv.lock`,
# and applies the changes packages for you
CMD ["uv", "run", "python", "-m", "app.main"]

# ---- Production stage ----
FROM base AS production

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy dependency files and install ONLY production dependencies
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev --no-install-project

# Copy source and install the project itself
COPY . .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev

# Switch to the non-privileged user
USER appuser

ENV PATH="/app/.venv/bin:$PATH"
EXPOSE 8000
CMD ["python", "-m", "app.main"]