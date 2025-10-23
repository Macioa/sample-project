# Use the official Elixir image as base
FROM elixir:1.15.7-otp-26-alpine

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    inotify-tools

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy the rest of the application
COPY . .

# Install assets dependencies
RUN mix assets.setup

# Build assets
RUN mix assets.build

# Create a non-root user
RUN adduser -D -s /bin/sh appuser && \
    chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 4000

# Default command
CMD ["mix", "phx.server"]
