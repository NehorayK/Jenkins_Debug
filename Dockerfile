# Dockerfile for your SSH-based Jenkins agent

FROM debian:bookworm-slim

# 1) Install JRE, SSHD, Git, Python3 (+ dev), venv support, binutils, wget & curl
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      default-jre-headless \
      openssh-server \
      git \
      python3 \
      python3-dev \
      python3-venv \
      binutils \
      wget \
      curl && \
    rm -rf /var/lib/apt/lists/* && \
    ldconfig

# 2) Build a virtualenv with your Python CLI tools
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip pyinstaller pylint flask && \
    ln -s /opt/venv/bin/pyinstaller /usr/local/bin/pyinstaller && \
    ln -s /opt/venv/bin/pylint     /usr/local/bin/pylint     && \
    ln -s /opt/venv/bin/flask      /usr/local/bin/flask      && \
    ln -s /opt/venv/bin/pip        /usr/local/bin/pip

# 3) Create the jenkins user & SSH workspace
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins && \
    echo 'jenkins:jenkinspass' | chpasswd && \
    mkdir -p /home/jenkins/agent /home/jenkins/.ssh /var/run/sshd && \
    chown -R jenkins:jenkins /home/jenkins

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]