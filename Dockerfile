# Dockerfile for SSH-based Jenkins agent with binutils

FROM debian:bookworm-slim

# 1) Install Java (for remoting), SSH server, Git, Python & binutils in one RUN
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      default-jre-headless \
      openssh-server \
      git \
      python3 \
      python3-venv \
      binutils \
      wget \
      curl && \
    rm -rf /var/lib/apt/lists/*

# 2) Create a Python venv and install PyInstaller, pylint, flask
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install pyinstaller pylint flask && \
    ln -s /opt/venv/bin/pyinstaller /usr/local/bin/pyinstaller && \
    ln -s /opt/venv/bin/pylint     /usr/local/bin/pylint     && \
    ln -s /opt/venv/bin/flask      /usr/local/bin/flask      && \
    ln -s /opt/venv/bin/pip        /usr/local/bin/pip

# 3) Set up jenkins user & workspace, and create sshd dir
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins && \
    echo 'jenkins:jenkinspass' | chpasswd && \
    mkdir -p /home/jenkins/agent /home/jenkins/.ssh /var/run/sshd && \
    chown -R jenkins:jenkins /home/jenkins

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]