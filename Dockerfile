FROM python:3.13-alpine

# Installer les dépendances système nécessaires
# hadolint ignore=DL3018
RUN apk add --no-cache --update \
    python3 \
    py3-pip \
    bash && \
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
ENV PORT 5000
EXPOSE 5000
# Copier le code de l'application
COPY ./webapp /opt/webapp/
WORKDIR /opt/webapp

# Créer un utilisateur non-root
RUN adduser -D myuser
USER myuser

# Utiliser la notation JSON pour CMD
CMD ["/bin/bash", "-c", "gunicorn run:app –bind 0.0.0.0:$PORT"]
#CMD ["gunicorn", "--bind", "0.0.0.0:$PORT", "wsgi"]
