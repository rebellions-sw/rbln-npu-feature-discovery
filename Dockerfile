# syntax=docker/dockerfile:1.4

FROM rust:1.84-alpine AS builder
RUN apk add --no-cache build-base protobuf-dev
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo fetch
COPY proto ./proto
COPY src ./src
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo build --release --locked --bin rbln-npu-feature-discovery && \
    cp /app/target/release/rbln-npu-feature-discovery /usr/local/bin/

FROM redhat/ubi9-minimal:9.6
ARG VERSION

# Create non-root user
RUN microdnf install -y shadow-utils && \
    groupadd -r rbln && \
    useradd -r -g rbln -d /home/rbln -s /sbin/nologin -c "RBLN NPU Feature Discovery user" rbln && \
    mkdir -p /home/rbln && \
    chown rbln:rbln /home/rbln && \
    microdnf clean all

COPY LICENSE /licenses/LICENSE.txt

LABEL \
    name="rbln-npu-feature-discovery" \
    vendor="Rebellions" \
    version="${VERSION}" \
    release="N/A" \
    summary="Rebellions NPU Feature Discovery" \
    description="NPU Feature Discovery extends Kubernetes Node Feature Discovery to automatically detect Rebellions NPUs on a node and generate the corresponding Kubernetes labels." \
    maintainer="Rebellions sw_devops@rebellions.ai" \
    io.k8s.display-name="Rebellions NPU Feature Discovery" \
    com.redhat.component="rbln-npu-feature-discovery"

COPY --from=builder /usr/local/bin/rbln-npu-feature-discovery /usr/bin/rbln-npu-feature-discovery

RUN chown rbln:rbln /usr/bin/rbln-npu-feature-discovery && \
    chmod 755 /usr/bin/rbln-npu-feature-discovery

USER rbln

ENV RUST_LOG=info
ENTRYPOINT ["/usr/bin/rbln-npu-feature-discovery"]
