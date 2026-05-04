# Stage 1: Build
FROM rust:1.95-slim-bookworm AS builder

# Install build dependencies for V8 and Rust
RUN apt-get update && apt-get install -y \
    python3 \
    git \
    libssl-dev \
    g++ \
    build-essential \
    cmake \
    pkg-config \
    clang \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/obscura
COPY . .

# Build with 'stealth' feature for agentic anti-detection
RUN cargo build --release --features stealth

# Stage 2: Runtime
FROM debian:bookworm-slim

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /usr/src/obscura/target/release/obscura /usr/local/bin/obscura

# Expose the CDP (Chrome DevTools Protocol) port
EXPOSE 9222

# Start the server in stealth mode
# --port 9222: Default CDP port
# --stealth: Enables tracker blocking & fingerprint masking
ENTRYPOINT ["obscura", "serve", "--port", "9222", "--stealth"]
