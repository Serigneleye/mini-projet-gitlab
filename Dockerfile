FROM python:3.18-alpine

# Installer les dépendances système nécessaires
RUN apk add --no-cache --update \
    python3=3.13.1 \
    py3-pip=24.3.1 \
    bash=5.2 && \
    rm -rf /var/cache/apk/*

# Copier le fichier requirements.txt
COPY ./webapp/requirements.txt /tmp/requirements.txt

# Créer un environnement virtuel et installer les dépendances Python
# hadolint ignore=SC1091
RUN python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --no-cache-dir -r /tmp/requirements.txt && \
    deactivate

# Ajouter le répertoire bin de l'environnement virtuel au PATH
ENV PATH="/opt/venv/bin:$PATH"

# Copier le code de l'application
COPY ./webapp /opt/webapp/
WORKDIR /opt/webapp

# Créer un utilisateur non-root
RUN adduser -D myuser
USER myuser

# Utiliser la notation JSON pour CMD
CMD ["gunicorn", "--bind", "0.0.0.0:$PORT", "wsgi"]
