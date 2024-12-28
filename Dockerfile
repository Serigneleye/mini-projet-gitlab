# Utiliser une version stable de Python avec Alpine
FROM python:3.10-alpine

# Installer les dépendances système avec des versions verrouillées
RUN apk add --no-cache --update \
    python3=3.10.9-r0 \
    py3-pip=22.3.1-r0 \
    bash=5.1.16-r0 && \
    rm -rf /var/cache/apk/*

# Copier le fichier requirements.txt
COPY ./webapp/requirements.txt /tmp/requirements.txt

# Installer les dépendances Python
RUN pip3 install --no-cache-dir -q -r /tmp/requirements.txt && \
    rm -rf /tmp/requirements.txt

# Ajouter le code source de l'application
COPY ./webapp /opt/webapp/
WORKDIR /opt/webapp

# Créer un utilisateur non-root
RUN adduser -D myuser
USER myuser

# Définir la commande de démarrage avec la notation JSON
CMD ["gunicorn", "--bind", "0.0.0.0:$PORT", "wsgi"]