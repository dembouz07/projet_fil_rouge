# Configuration Webhook Git et Notifications Email

Ce guide explique comment configurer Jenkins pour declencher automatiquement les builds lors d'un push Git et envoyer des notifications par email.

---

## PARTIE 1 : Configuration des Notifications Email

### Etape 1 : Installer le plugin Email Extension

1. Allez dans **Manage Jenkins** > **Manage Plugins**
2. Cliquez sur l'onglet **Available plugins**
3. Recherchez **Email Extension Plugin**
4. Cochez la case et cliquez sur **Install without restart**
5. Attendez la fin de l'installation

### Etape 2 : Configurer le serveur SMTP

1. Allez dans **Manage Jenkins** > **Configure System**
2. Descendez jusqu'a la section **Extended E-mail Notification**

#### Configuration pour Gmail :

```
SMTP server: smtp.gmail.com
SMTP Port: 465
```

3. Cliquez sur **Advanced**
4. Cochez **Use SSL**
5. Cliquez sur **Add** a cote de **Credentials**
   - Kind: Username with password
   - Username: votre.email@gmail.com
   - Password: [Mot de passe d'application Gmail - voir ci-dessous]
   - ID: gmail-smtp
   - Description: Gmail SMTP

6. Selectionnez les credentials que vous venez de creer
7. **Default Recipients**: Entrez votre email (ex: votre.email@gmail.com)
8. Cochez **Use SSL**

#### Configuration pour Outlook/Hotmail :

```
SMTP server: smtp-mail.outlook.com
SMTP Port: 587
```

3. Cliquez sur **Advanced**
4. Cochez **Use TLS**
5. Ajoutez vos credentials Outlook

#### Configuration pour un serveur SMTP personnalise :

```
SMTP server: smtp.votre-domaine.com
SMTP Port: 587 (ou 465 pour SSL)
```

### Etape 3 : Creer un mot de passe d'application Gmail

Si vous utilisez Gmail, vous devez creer un mot de passe d'application :

1. Allez sur https://myaccount.google.com/security
2. Activez la **verification en deux etapes** si ce n'est pas deja fait
3. Recherchez **Mots de passe des applications**
4. Selectionnez **Autre (nom personnalise)**
5. Entrez "Jenkins" et cliquez sur **Generer**
6. Copiez le mot de passe genere (16 caracteres)
7. Utilisez ce mot de passe dans les credentials Jenkins

### Etape 4 : Tester la configuration email

1. Dans la section **Extended E-mail Notification**, cliquez sur **Test configuration**
2. Entrez votre email dans **Test e-mail recipient**
3. Cliquez sur **Test configuration**
4. Verifiez que vous recevez l'email de test

### Etape 5 : Configurer les emails par defaut

Descendez jusqu'a la section **E-mail Notification** (plus bas dans la page) :

1. **SMTP server**: smtp.gmail.com (ou votre serveur)
2. Cliquez sur **Advanced**
3. Cochez **Use SMTP Authentication**
   - User Name: votre.email@gmail.com
   - Password: [Mot de passe d'application]
4. Cochez **Use SSL**
5. **SMTP Port**: 465
6. **Reply-To Address**: votre.email@gmail.com
7. Cliquez sur **Test configuration by sending test e-mail**
8. Cliquez sur **Save**

---

## PARTIE 2 : Declenchement Automatique sur Push Git

### Option A : Polling SCM (Recommande pour debuter)

Cette option est deja configuree dans le Jenkinsfile :

```groovy
triggers {
    pollSCM('H/5 * * * *')
}
```

Cela verifie les changements Git toutes les 5 minutes.

**Configuration dans Jenkins :**

1. Allez dans votre projet **portfolio-cicd**
2. Cliquez sur **Configure**
3. Dans la section **Build Triggers**
4. Verifiez que **Poll SCM** est coche
5. Le schedule devrait etre : `H/5 * * * *`
6. Cliquez sur **Save**

**Explication du schedule :**
- `H/5 * * * *` : Toutes les 5 minutes
- `H/2 * * * *` : Toutes les 2 minutes
- `H/10 * * * *` : Toutes les 10 minutes
- `H * * * *` : Toutes les heures

### Option B : Webhook GitHub (Pour production)

Si votre code est sur GitHub :

#### 1. Configurer le webhook sur GitHub

1. Allez sur votre repository GitHub
2. Cliquez sur **Settings** > **Webhooks** > **Add webhook**
3. **Payload URL**: `http://VOTRE_IP:8081/github-webhook/`
   - Remplacez `VOTRE_IP` par votre adresse IP publique
   - Exemple: `http://192.168.1.100:8081/github-webhook/`
4. **Content type**: `application/json`
5. **Which events**: Selectionnez **Just the push event**
6. Cochez **Active**
7. Cliquez sur **Add webhook**

#### 2. Installer le plugin GitHub

1. **Manage Jenkins** > **Manage Plugins**
2. Recherchez **GitHub Plugin**
3. Installez-le

#### 3. Configurer Jenkins

1. Allez dans votre projet **portfolio-cicd**
2. Cliquez sur **Configure**
3. Dans **Build Triggers**, cochez **GitHub hook trigger for GITScm polling**
4. Cliquez sur **Save**

#### 4. Mettre a jour le Jenkinsfile

Remplacez :
```groovy
triggers {
    pollSCM('H/5 * * * *')
}
```

Par :
```groovy
triggers {
    githubPush()
}
```

### Option C : Webhook GitLab

Si votre code est sur GitLab :

#### 1. Installer le plugin GitLab

1. **Manage Jenkins** > **Manage Plugins**
2. Recherchez **GitLab Plugin**
3. Installez-le

#### 2. Configurer le webhook sur GitLab

1. Allez sur votre projet GitLab
2. **Settings** > **Webhooks**
3. **URL**: `http://VOTRE_IP:8081/project/portfolio-cicd`
4. **Secret Token**: (laissez vide ou generez-en un)
5. Cochez **Push events**
6. Cliquez sur **Add webhook**

#### 3. Configurer Jenkins

1. Allez dans votre projet **portfolio-cicd**
2. Cliquez sur **Configure**
3. Dans **Build Triggers**, cochez **Build when a change is pushed to GitLab**
4. Cliquez sur **Save**

---

## PARTIE 3 : Tester la Configuration

### Test 1 : Verifier le polling SCM

1. Faites un changement dans votre code
2. Commitez et pushez :
   ```bash
   git add .
   git commit -m "Test auto-trigger"
   git push
   ```
3. Attendez 5 minutes maximum
4. Jenkins devrait automatiquement demarrer un nouveau build

### Test 2 : Verifier les emails

1. Attendez la fin du build
2. Verifiez votre boite email
3. Vous devriez recevoir un email avec :
   - Le statut du build (succes ou echec)
   - Les details du build
   - Un lien vers Jenkins

---

## PARTIE 4 : Personnaliser les Emails

### Modifier les destinataires

Dans le Jenkinsfile, vous pouvez specifier plusieurs destinataires :

```groovy
emailext(
    to: 'email1@example.com, email2@example.com',
    // ...
)
```

### Ajouter des pieces jointes

```groovy
emailext(
    attachLog: true,
    attachmentsPattern: '**/target/*.jar',
    // ...
)
```

### Modifier le template d'email

Vous pouvez personnaliser le contenu HTML dans la section `body` du Jenkinsfile.

---

## Troubleshooting

### Les emails ne sont pas envoyes

1. Verifiez les logs Jenkins : **Manage Jenkins** > **System Log**
2. Verifiez que le plugin Email Extension est installe
3. Testez la configuration SMTP dans **Configure System**
4. Verifiez que vous utilisez un mot de passe d'application (Gmail)
5. Verifiez les parametres du pare-feu

### Le polling ne fonctionne pas

1. Verifiez que Jenkins a acces au repository Git
2. Verifiez les credentials Git dans Jenkins
3. Consultez les logs de polling : Projet > **Git Polling Log**

### Le webhook ne fonctionne pas

1. Verifiez que Jenkins est accessible depuis Internet
2. Verifiez l'URL du webhook
3. Consultez les logs du webhook sur GitHub/GitLab
4. Verifiez que le plugin GitHub/GitLab est installe

---

## Configuration Recommandee

Pour un environnement de developpement :
- Utilisez **Poll SCM** avec `H/5 * * * *` (toutes les 5 minutes)
- Configurez les emails pour les echecs uniquement

Pour un environnement de production :
- Utilisez les **Webhooks** pour un declenchement instantane
- Configurez les emails pour tous les builds
- Ajoutez des notifications Slack/Teams si necessaire

---

## Prochaines Etapes

1. Configurez le serveur SMTP dans Jenkins
2. Testez l'envoi d'emails
3. Activez le polling SCM ou configurez un webhook
4. Faites un push de test
5. Verifiez que le build se declenche automatiquement
6. Verifiez la reception de l'email

Votre pipeline CI/CD est maintenant completement automatise !
