# Guide Étape par Étape : Configuration Email Jenkins

Ce guide vous accompagne pas à pas pour configurer l'envoi d'emails depuis Jenkins vers **ousinfaye4@gmail.com**.

---

## PARTIE 1 : Créer un Mot de Passe d'Application Gmail

### Étape 1 : Activer la vérification en deux étapes

1. Ouvrez votre navigateur
2. Allez sur : https://myaccount.google.com/security
3. Connectez-vous avec **ousinfaye4@gmail.com**
4. Cherchez la section **"Connexion à Google"**
5. Cliquez sur **"Validation en deux étapes"** ou **"2-Step Verification"**
6. Si ce n'est pas activé, cliquez sur **"Activer"** et suivez les instructions
7. Configurez votre téléphone pour recevoir les codes

### Étape 2 : Créer un mot de passe d'application

1. Retournez sur https://myaccount.google.com/security
2. Cherchez **"Mots de passe des applications"** ou **"App passwords"**
   - Si vous ne le voyez pas, tapez "app passwords" dans la barre de recherche en haut
3. Cliquez sur **"Mots de passe des applications"**
4. Google peut vous demander votre mot de passe, entrez-le
5. Vous verrez une page avec un menu déroulant
6. Dans le premier menu, sélectionnez **"Autre (nom personnalisé)"**
7. Tapez : **Jenkins**
8. Cliquez sur **"Générer"**
9. Google affiche un mot de passe de 16 caractères comme : **abcd efgh ijkl mnop**
10. **IMPORTANT** : Copiez ce mot de passe (sans les espaces) : **abcdefghijklmnop**
11. Gardez ce mot de passe, vous en aurez besoin dans Jenkins

---

## PARTIE 2 : Installer le Plugin Email dans Jenkins

### Étape 1 : Ouvrir Jenkins

1. Ouvrez votre navigateur
2. Allez sur : http://localhost:8081
3. Connectez-vous avec vos identifiants Jenkins

### Étape 2 : Installer le plugin Email Extension

1. Dans le menu de gauche, cliquez sur **"Manage Jenkins"** (Administrer Jenkins)
2. Cliquez sur **"Manage Plugins"** (Gérer les plugins)
3. Cliquez sur l'onglet **"Available plugins"** (Plugins disponibles)
4. Dans la barre de recherche en haut à droite, tapez : **Email Extension**
5. Cochez la case à côté de **"Email Extension Plugin"**
6. En bas de la page, cliquez sur **"Install without restart"** (Installer sans redémarrer)
7. Attendez que l'installation se termine (barre verte = terminé)
8. Cliquez sur **"Go back to the top page"** (Retour à la page d'accueil)

---

## PARTIE 3 : Configurer le Serveur SMTP dans Jenkins

### Étape 1 : Ouvrir la configuration système

1. Dans le menu de gauche, cliquez sur **"Manage Jenkins"**
2. Cliquez sur **"Configure System"** (Configurer le système)
3. Vous êtes maintenant sur une longue page de configuration

### Étape 2 : Configurer "Extended E-mail Notification"

1. **Descendez** jusqu'à trouver la section **"Extended E-mail Notification"**
2. Remplissez les champs suivants :

   **SMTP server** (serveur SMTP) :
   ```
   smtp.gmail.com
   ```

   **SMTP Port** (port SMTP) :
   ```
   587
   ```

   **Default user E-mail suffix** (laissez vide)

3. Cliquez sur le bouton **"Advanced..."** (Avancé) à droite

4. Une nouvelle section s'ouvre. Remplissez :

   **Cochez** la case **"Use SMTP Authentication"** (Utiliser l'authentification SMTP)

   **User Name** (Nom d'utilisateur) :
   ```
   ousinfaye4@gmail.com
   ```

   **Password** (Mot de passe) :
   ```
   [Collez ici le mot de passe d'application de 16 caractères créé à l'étape 1]
   ```
   Exemple : abcdefghijklmnop (sans espaces)

   **Cochez** la case **"Use TLS"** (Utiliser TLS)
   
   **IMPORTANT** : NE cochez PAS "Use SSL"

   **SMTP port** :
   ```
   587
   ```

5. Dans le champ **"Default Recipients"** (Destinataires par défaut) :
   ```
   ousinfaye4@gmail.com
   ```

6. **Charset** : laissez **UTF-8**

7. **Default Content Type** : laissez **text/plain**

### Étape 3 : Tester la configuration Extended E-mail

1. Toujours dans la section "Extended E-mail Notification"
2. Cherchez le bouton **"Test configuration by sending test e-mail"**
3. Dans le champ **"Test e-mail recipient"**, tapez :
   ```
   ousinfaye4@gmail.com
   ```
4. Cliquez sur **"Test configuration"**
5. Vous devriez voir un message : **"Email was successfully sent"**
6. Vérifiez votre boîte email **ousinfaye4@gmail.com**
7. Vous devriez avoir reçu un email de test

**Si vous avez une erreur** :
- Vérifiez que vous avez bien utilisé le mot de passe d'application (pas votre mot de passe Gmail normal)
- Vérifiez que "Use TLS" est coché et "Use SSL" est décoché
- Vérifiez que le port est bien 587

### Étape 4 : Configurer "E-mail Notification"

1. **Descendez encore** jusqu'à trouver la section **"E-mail Notification"** (plus bas dans la page)
2. Remplissez les champs suivants :

   **SMTP server** :
   ```
   smtp.gmail.com
   ```

3. Cliquez sur le bouton **"Advanced..."** à droite

4. Une nouvelle section s'ouvre. Remplissez :

   **Cochez** la case **"Use SMTP Authentication"**

   **User Name** :
   ```
   ousinfaye4@gmail.com
   ```

   **Password** :
   ```
   [Le même mot de passe d'application de 16 caractères]
   ```

   **Cochez** la case **"Use TLS"**
   
   **NE cochez PAS** "Use SSL"

   **SMTP Port** :
   ```
   587
   ```

5. Dans le champ **"Reply-To Address"** :
   ```
   ousinfaye4@gmail.com
   ```

6. **Charset** : laissez **UTF-8**

### Étape 5 : Tester la configuration E-mail Notification

1. Toujours dans la section "E-mail Notification"
2. Cochez la case **"Test configuration by sending test e-mail"**
3. Dans le champ **"Test e-mail recipient"**, tapez :
   ```
   ousinfaye4@gmail.com
   ```
4. Cliquez sur le bouton à côté (peut être "Test configuration" ou une icône)
5. Vous devriez voir un message de succès
6. Vérifiez votre boîte email

### Étape 6 : Sauvegarder

1. **Descendez tout en bas** de la page
2. Cliquez sur le gros bouton bleu **"Save"** (Enregistrer)
3. Vous revenez à la page d'accueil Jenkins

---

## PARTIE 4 : Tester avec un Build Jenkins

### Étape 1 : Lancer un build

1. Sur la page d'accueil Jenkins, cliquez sur votre projet **"portfolio-cicd"**
2. Dans le menu de gauche, cliquez sur **"Build Now"** (Construire maintenant)
3. Un nouveau build apparaît dans **"Build History"** (Historique des builds)
4. Attendez que le build se termine (quelques minutes)

### Étape 2 : Vérifier l'email

1. Quand le build est terminé (vert = succès, rouge = échec)
2. Ouvrez votre boîte email **ousinfaye4@gmail.com**
3. Vous devriez avoir reçu un email avec :
   - **Sujet** : "Build reussi : portfolio-cicd - Build #XX" (si succès)
   - **Sujet** : "Build echoue : portfolio-cicd - Build #XX" (si échec)
4. L'email contient :
   - Le statut du build
   - Les images Docker déployées
   - Un lien vers Jenkins pour voir les détails

---

## PARTIE 5 : Activer le Déclenchement Automatique

### Étape 1 : Configurer le projet

1. Sur la page d'accueil Jenkins, cliquez sur **"portfolio-cicd"**
2. Dans le menu de gauche, cliquez sur **"Configure"** (Configurer)
3. Descendez jusqu'à la section **"Build Triggers"** (Déclencheurs de build)
4. **Cochez** la case **"Poll SCM"**
5. Dans le champ **"Schedule"**, tapez :
   ```
   H/5 * * * *
   ```
   Cela signifie : vérifier les changements Git toutes les 5 minutes

6. Descendez en bas et cliquez sur **"Save"**

### Étape 2 : Tester le déclenchement automatique

1. Ouvrez votre projet dans VS Code ou votre éditeur
2. Faites un petit changement (par exemple, ajoutez un commentaire dans un fichier)
3. Ouvrez un terminal et tapez :
   ```bash
   git add .
   git commit -m "Test auto-trigger Jenkins"
   git push
   ```
4. Attendez maximum 5 minutes
5. Retournez sur Jenkins
6. Un nouveau build devrait démarrer automatiquement
7. Quand il se termine, vous recevrez un email automatiquement

---

## Récapitulatif de la Configuration

### Configuration Gmail :
- **Email** : ousinfaye4@gmail.com
- **Mot de passe** : Mot de passe d'application de 16 caractères (pas votre mot de passe Gmail normal)
- **Vérification en deux étapes** : Activée (obligatoire)

### Configuration Jenkins SMTP :
- **Serveur** : smtp.gmail.com
- **Port** : 587
- **TLS** : Activé ✓
- **SSL** : Désactivé ✗
- **Authentification** : Activée
- **Username** : ousinfaye4@gmail.com
- **Password** : Mot de passe d'application

### Déclenchement automatique :
- **Poll SCM** : H/5 * * * * (toutes les 5 minutes)
- **Action** : Push sur Git → Jenkins détecte → Build automatique → Email envoyé

---

## Troubleshooting (Résolution de problèmes)

### Problème 1 : "Must issue a STARTTLS command first"

**Solution** :
- Vérifiez que vous utilisez le port **587** (pas 465)
- Vérifiez que **"Use TLS"** est coché
- Vérifiez que **"Use SSL"** est décoché

### Problème 2 : "Authentication failed"

**Solution** :
- Vérifiez que vous utilisez le **mot de passe d'application** (16 caractères)
- Ne pas utiliser votre mot de passe Gmail normal
- Vérifiez que la vérification en deux étapes est activée sur Gmail
- Recréez un nouveau mot de passe d'application si nécessaire

### Problème 3 : "Connection timed out"

**Solution** :
- Vérifiez votre connexion Internet
- Vérifiez que votre pare-feu n'bloque pas le port 587
- Essayez de désactiver temporairement l'antivirus

### Problème 4 : Je ne reçois pas d'email

**Solution** :
- Vérifiez votre dossier **Spam** ou **Courrier indésirable**
- Vérifiez que l'email de test a bien fonctionné dans Jenkins
- Vérifiez les logs Jenkins : Manage Jenkins > System Log
- Relancez un build pour tester

### Problème 5 : Le build ne se déclenche pas automatiquement

**Solution** :
- Vérifiez que "Poll SCM" est bien coché dans la configuration du projet
- Vérifiez que le schedule est bien : H/5 * * * *
- Attendez au moins 5 minutes après le push
- Vérifiez les logs de polling : Projet > Git Polling Log (dans le menu de gauche)

---

## Aide Supplémentaire

Si vous avez encore des problèmes :

1. **Vérifiez les logs Jenkins** :
   - Manage Jenkins > System Log
   - Cherchez les erreurs liées à "mail" ou "smtp"

2. **Testez manuellement** :
   - Ouvrez un terminal
   - Testez la connexion SMTP :
   ```bash
   telnet smtp.gmail.com 587
   ```
   - Si ça ne fonctionne pas, c'est un problème réseau/pare-feu

3. **Recréez le mot de passe d'application** :
   - Supprimez l'ancien mot de passe d'application sur Google
   - Créez-en un nouveau
   - Mettez à jour dans Jenkins

---

## Résumé des Étapes

1. ✓ Créer un mot de passe d'application Gmail
2. ✓ Installer le plugin Email Extension dans Jenkins
3. ✓ Configurer Extended E-mail Notification (SMTP, TLS, port 587)
4. ✓ Configurer E-mail Notification (même configuration)
5. ✓ Tester l'envoi d'email
6. ✓ Sauvegarder la configuration
7. ✓ Activer Poll SCM pour le déclenchement automatique
8. ✓ Tester avec un push Git

Votre pipeline CI/CD est maintenant complètement automatisé avec notifications email !
