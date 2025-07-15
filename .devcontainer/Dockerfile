# --- A Simple, Single-Stage Dockerfile for Flutter with Java 11 ---
FROM ubuntu:22.04

# Define arguments for versions
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
ARG FLUTTER_VERSION="3.29.3"
ARG ANDROID_CMD_TOOLS_VERSION="9477386"
ARG ANDROID_PLATFORM_VERSION="34"
ARG ANDROID_BUILD_TOOLS_VERSION="34.0.0"
ARG ANDROID_NDK_VERSION="27.0.12077973"
ARG JAVA_VERSION="17"

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install all dependencies in one go: Java 11, build tools, git, etc.
# *** THE FIX: Add flags to apt-get update to ignore time-based validation ***
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    unzip \
    sudo \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libglu1-mesa \
    libusb-1.0-0 \
    libc6 \
    libncurses6 \
    libstdc++6 \
    lib32z1 \
    openjdk-${JAVA_VERSION}-jdk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user 'vscode'
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Switch to the non-root user
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Set up all environment variables
ENV JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"
ENV ANDROID_SDK_ROOT="/home/${USERNAME}/android-sdk"
ENV FLUTTER_HOME="/home/${USERNAME}/flutter"
ENV PATH="${FLUTTER_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK_VERSION}:${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Install Android SDK
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && cd ${ANDROID_SDK_ROOT} && \
    curl -o cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMD_TOOLS_VERSION}_latest.zip" && \
    unzip -q cmdline-tools.zip -d cmdline-tools && \
    mv cmdline-tools/cmdline-tools cmdline-tools/latest && \
    rm cmdline-tools.zip && \
    yes | sdkmanager --licenses >/dev/null && \
    sdkmanager "platform-tools" \
               "platforms;android-${ANDROID_PLATFORM_VERSION}" \
               "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
               "ndk;${ANDROID_NDK_VERSION}" && \
    yes | sdkmanager --licenses >/dev/null

# Install Flutter SDK
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    flutter --version && \
    flutter config --no-analytics && \
    flutter config --no-enable-linux-desktop && \
    flutter config --no-enable-windows-desktop && \
    flutter config --no-enable-web && \
    flutter config --no-enable-macos-desktop && \
    yes | flutter doctor --android-licenses && \
    flutter precache

# Verify the final setup
RUN flutter doctor