# 1) Pick a slim Debian base
FROM debian:bookworm-slim

# 2) In one RUN, install Java for remoting, SSH, Git, Python with shared libs,
#    binutils (for objdump), venv support, and cleanup apt caches.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      default-jre-headless \
      openssh-server \
      git \
      python3-full \
      python3-venv \
      binutils \
      wget \
      curl && \
    rm -rf /var/lib/apt/lists/*

# 3) Create a Python virtualenv and install your build tools (PyInstaller, pylint, flask).
#    Then symlink them into /usr/local/bin so they’re on PATH.
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install pyinstaller pylint flask && \
    ln -s /opt/venv/bin/pyinstaller /usr/local/bin/pyinstaller && \
    ln -s /opt/venv/bin/pylint     /usr/local/bin/pylint     && \
    ln -s /opt/venv/bin/flask      /usr/local/bin/flask      && \
    ln -s /opt/venv/bin/pip        /usr/local/bin/pip

# 4) Add the jenkins user, set its password, create the workspace & SSH dirs.
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins && \
    echo 'jenkins:jenkinspass' | chpasswd && \
    mkdir -p /home/jenkins/agent /home/jenkins/.ssh /var/run/sshd && \
    chown -R jenkins:jenkins /home/jenkins

# 5) Expose SSH and run it in the foreground
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]