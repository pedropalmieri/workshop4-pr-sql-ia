FROM ghcr.io/actions/actions-runner@sha256:6d0b2d80d80f143f77dcb676e50920100bbb547e39e883454d57f45ab8c31300
USER root
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client python3-venv && rm -rf /var/lib/apt/lists/*
COPY infra/validacao/requirements.txt /tmp/ws4-requirements.txt
RUN python3 -m venv /opt/ws4 && /opt/ws4/bin/pip install --no-cache-dir -r /tmp/ws4-requirements.txt
USER runner
WORKDIR /home/runner
