# LES TOILES DE MINUIT - GESTIONNAIRE D'ÉVÈNEMENTS

Projet réalisé dans le cadre du test technique *"Les Toiles de Minuit"*.
L'application permet de gérer des évènements (création, modification, suppression, visualisation) avec un système d'authentification **par rôles (admin / user)**.

Frontend : **Flutter (web)**
Backend : **Symfony (API REST + JWT)**
Base de données : **MySQL**


------------------------------------------------


## Fonctionnalités principales :

- Authentification par **JWT** (connexion avec email + mot de passe).
- Gestion des rôles :
    - **Admin** : peut créer, modifier, supprimer des évènements.
    - **User** : accès en lecture seule.
- Gestion des évènements : 
    - Création avec validation des champs requis.
    - Modification avec formulaire pré-rempli.
    - Suppression avec confirmation.
- Interface moderne, minimaliste avec rappel des couleurs **bleu nuit** et **doré**.


------------------------------------------------


## Structure du projet :

event-app/
    |___ app/
    |       |__event_app/       #Frontend Flutter
    |
    |___ backend/
    |       |__symfony/         #Backend Symfony
    |
    |___ docs/                  #Documentation complète
    |
    |___ README.md              #Présentation et guide rapide


------------------------------------------------


## Prérequis :

Avant de lancer l'application, assurez-vous d'avoir installé :

- [Flutter](https://docs.flutter.dev/get-started/install)
- [PHP & Composer](https://getcomposer.org/download)
- [Docker](https://docs.docker.com/get-docker) => (pour MySQL & phpMyAdmin)
- [Node.js & npm](https://nodejs.org/) => (si vous utilisez Symfony encore avec Webpack encore)

Les étapes détaillées d'installation sont disponibles dans la documentation.


------------------------------------------------


## Installation rapide :

1. Cloner le projet :
    ```bash
    git clone https://github.com/aliciakellai/event-app.git
    cd event-app

2. Installer le backend (Symfony) :
    cd backend/symfony
    composer install

    2.a. Configurer les variables d'environnement :
        cp .env.example .env

    2.b. Modifier .env avec vos identifiants MySQL

    2.c. Lancer le serveur Symfony :
        symfony server:start

3. Installer le frontend (Flutter) :
    cd ../../app/event-app
    flutter pub get

    3.a. Configurer l'URL de l'API dans .env :
    FLUTTER_API_URL=http://127.0.0.1:8000/api

    3.b. Lancer l'application :
    flutter run -d chrome

4. Authentification :

*Deux comptes ont été préconfigurés. Vous pouvez les utiliser si vous ne souhaitez pas créer de comptes.*
*Compte Admin : **Email :** admin@test.com **Mot de passe :** admin*
*Compte User : **Email :** user@test.com **Mot de passe :** user*

    4.a. Créez un utilisateur admin manuellement :
        php bin/console security:hash-password

    4.b. Copiez le hash généré et inséré dans la base (users), avec rôle ["ROLE_ADMIN"]
    
    4.c. Connectez-vous ensuite avec vos identifiants sur l'interface

5. Tests :

    5.a. Lancez les containers MySQL & phpMyAdmin :
        docker-compose up -d

    5.b. Accédez à **phpMyAdmin** : http://localhost:8081

    5.c. Vérifiez que vos évènements apparaissent bien dans la base.



------------------------------------------------


# Documentation :

Pour les explications détaillées, voir la documentation complète dans le dossier \docs.
- Installation pas à pas (Symfony, Flutter, Docker)
- Utilisation de l'application
- Gestion des rôles et authentification
- Schéma de la base de données


------------------------------------------------


# Auteur :

Projet réalisé par Alicia Kellai, dans le cadre du test technique *Les Toiles de Minuit*.



