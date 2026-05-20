# Cuis Smalltalk — Multi-stage, multi-arch Dockerfile
#
# Supported platforms: linux/amd64, linux/arm64
# Both VMs require GLIBC >= 2.34 → Ubuntu 22.04 (glibc 2.35)
#
# Stages:
#   vm            — OS + VM binary + plugins only. Stable, cached.
#   image-updated — extends vm, applies all CoreUpdates to the Smalltalk image.
#   test          — extends image-updated, runs the full test suite.
#   runtime       — minimal image to run Cuis. No CoreUpdates, no CI scripts.
#
# Build all stages up to runtime (single arch):
#   docker build --target runtime -t cuis:latest .
#
# Build multi-arch and push to a registry:
#   docker buildx build --platform linux/amd64,linux/arm64 \
#     --target runtime --push -t ghcr.io/<org>/cuis:latest .

# ── Stage 1: vm ──────────────────────────────────────────────────────────────
FROM ubuntu:22.04 AS vm

# Minimal runtime deps for the Squeak VM
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libssl3 \
      libstdc++6 \
      libgcc-s1 \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Select the right VM bundle for the current build platform.
# TARGETARCH is set automatically by buildx: "amd64" or "arm64".
ARG TARGETARCH
RUN echo "Building for $TARGETARCH"

COPY CuisVM.app/Contents/Linux-x86_64/ /opt/cuis-vm/amd64/
COPY CuisVM.app/Contents/Linux-arm64/  /opt/cuis-vm/arm64/

# Symlink the correct arch into /opt/cuis-vm/current
RUN ln -s /opt/cuis-vm/${TARGETARCH} /opt/cuis-vm/current \
 && chmod +x /opt/cuis-vm/current/squeak \
 && chmod +x /opt/cuis-vm/current/lib/squeak/*/squeak

# Smoke-test: VM must print version and exit 0
RUN /opt/cuis-vm/current/squeak --version

ENV CUIS_VM=/opt/cuis-vm/current/squeak
ENV CUIS_VM_ARGS="-vm-sound-null -vm-display-null"

WORKDIR /workspace

# ── Stage 2: image-updated ────────────────────────────────────────────────────
FROM vm AS image-updated

COPY CuisImage/          /workspace/CuisImage/
COPY CoreUpdates/        /workspace/CoreUpdates/
COPY .github/scripts/    /workspace/.github/scripts/
RUN chmod +x /workspace/.github/scripts/*.sh

RUN cd /workspace \
 && RUNNER_OS=Linux \
      CUIS_VM_PATH="$CUIS_VM" \
      CUIS_VM_ARGUMENTS="$CUIS_VM_ARGS" \
      .github/scripts/install-updates.sh

# ── Stage 3: runtime ─────────────────────────────────────────────────────────
# Minimal image to run Cuis.
# Contains: updated image + VM for this arch + fonts. Nothing else.
# Tests are run separately via 'docker run --security-opt seccomp=unconfined'
# because the Squeak JIT requires mprotect(PROT_READ|PROT_EXEC) which is
# blocked inside a Docker build RUN step on ARM64.
FROM vm AS runtime

COPY --from=image-updated /workspace/CuisImage/*.image   /workspace/CuisImage/
COPY --from=image-updated /workspace/CuisImage/*.changes /workspace/CuisImage/
COPY --from=image-updated /workspace/CuisImage/*.sources /workspace/CuisImage/
COPY --from=image-updated /workspace/CuisImage/UnicodeData.txt /workspace/CuisImage/

COPY TrueTypeFonts/ /workspace/TrueTypeFonts/

# Default: launch Cuis headlessly (override CMD for interactive use)
CMD ["sh", "-c", \
  "exec $CUIS_VM $CUIS_VM_ARGS \
   $(ls /workspace/CuisImage/*.image | head -1)"]
