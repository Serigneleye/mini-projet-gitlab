#L'objectif de ce projet est de créer une pipeline d'intégration continue (CI) et de déploiement continu (CD) pour le déploiement d'une application web Flask sur un serveur accessible via SSH.

Nous avons introduit les stages demandés comme suit :

#Linter pour la validation syntaxique
-Realiser un premier job qui fait le scan avec flake8.
-Installer Flake8 dans un environnement virtuel puis lancer la commande flake8 suivante:

    - flake8 --ignore=E501,E303 .
les erreurs corrigées par la suite :
<img width="462" alt="erreurflake8" src="https://github.com/user-attachments/assets/b4a0602b-1d23-4340-b0d2-bc395b4bc744" />


-Realiser un 2e job qui fait le hadolint
-Installer Hadolint et faire le scan avec

    - apk add --no-cache wget
    - wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
    - chmod +x /usr/local/bin/hadolint
    - hadolint Dockerfile
- il y a eu pas mal d'erreurs que j'ai dues corriger

#Compilation du code source avec comme artefact une image docker de l'app.

-Avec un simple job je fait la compilation du code avec comme resultat l'image gitlabprojet

    - docker build -t gitlabprojet .

#Analyse de l'image Docker pour détecter les vulnérabilités de sécurité avec Trivy.
- Installer Trivy avec le tar gz du github de aquasecurity puis le dezipper 

        - wget --no-verbose https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz -O - | tar -zxvf -

- Recuperer l'image puis lancer la commande de scan

        - docker load < gitlabprojet.tar
        - ./trivy image --severity HIGH,CRITICAL --exit-code 1 --no-progress gitlabprojet


#Tests Automatisés
- Recuperation de l'image et lancement du test avec la commande suivante
            - docker run -d -p 80:5000 --env PORT=5000 --name gitlabprojet gitlabprojet python test.py

#Vérification de la Qualité de Code
- Creation de compte sonarcloud 
- creation de l'organition et du projet
- generation de token
- configuration dans gitlab des variables : sonar token et SONAR_HOST_URL
  ![image](https://github.com/user-attachments/assets/3bcf2404-363c-4a50-92e3-07be5825d5d0)

- creation fichier sonar-project.properties  avec les variables :
      
                sonar.projectKey=gitlabprojet_gitlabprojet
                sonar.organization=gitlabprojet

- Definition de l'image de base et commande sonarscanner
                name: sonarsource/sonar-scanner-cli:latest
                - sonar-scanner
Resultat obtenu sur l'interface sonar
![image](https://github.com/user-attachments/assets/919a9a80-4b12-49c5-8f86-f98ca8cfb911)

#Packaging
-Recuperation de l'image, tag et pushh
    - docker tag gitlabprojet "$CI_REGISTRY_IMAGE:${CI_COMMIT_SHORT_SHA}"
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
    - docker push  "$CI_REGISTRY_IMAGE:${CI_COMMIT_REF_SLUG}"

#Déploiement dynamique en Review
Recuperation de ce qui a été fait pendant les tps sauf que y avait une erreur comme : $PORT is not a valid number. Nous avons du ajouter "bin/bash" dans le CMD du dockerfile.

#Staging
- connection ssh sur le serveur
- pull de l'image depuis le REGISTRY
- lancement du run pour le conteneur 
                  - command4="docker run -d -p 80:5000 -e PORT=5000 --name gitlabprojet
#Production
- connection ssh sur le serveur
- pull de l'image depuis le REGISTRY
- lancement du run pour le conteneur 
                  - command4="docker run -d -p 80:5000 -e PORT=5000 --name gitlabprojet

#Tests de Validation des Déploiements
- Comme en tp nous avons fait un template et l'utiliser pour testerr le deploiement
test prod:
  <<: *test
  stage: Test prod
  variables:
    DOMAIN: ${HOSTNAME_DEPLOY_PROD}
<img width="459" alt="page hello world" src="https://github.com/user-attachments/assets/29a87454-e26f-4050-a079-84f18e07253f" />
