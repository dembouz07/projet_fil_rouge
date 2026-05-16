# 🎯 Configuration Jenkins - Interface Web

## 📋 Étapes de Configuration

### ✅ Étape 1 : Créer les Credentials

#### 1.1 Ajouter GitHub Token

1. Cliquer sur **Manage Jenkins** (icône ⚙️ en haut à droite)
2. Cliquer sur **Manage Credentials**
3. Cliquer sur **(global)** sous "Stores scoped to Jenkins"
4. Cliquer sur **Add Credentials** (à gauche)
5. Remplir le formulaire :
   - **Kind** : `Secret text`
   - **Scope** : `Global`
   - **Secret** : [Coller votre GitHub Personal Access Token]
   - **ID** : `github-token`
   - **Description** : `GitHub Personal Access Token`
6. Cliquer sur **Create**

**Comment créer un GitHub Token :**
- Aller sur : https://github.com/settings/tokens
- Cliquer sur **Generate new token** → **Generate new token (classic)**
- Nom : `Jenkins CI/CD`
- Cocher : `repo` (tous les sous-items) + `admin:repo_hook`
- Cliquer sur **Generate token**
- **⚠️ COPIER LE TOKEN** immédiatement

---

#### 1.2 Ajouter Docker Hub Credentials

1. Toujours dans **Manage Credentials** → **(global)**
2. Cliquer sur **Add Credentials**
3. Remplir le formulaire :
   - **Kind** : `Username with password`
   - **Scope** : `Global`
   - **Username** : `dembouz7`
   - **Password** : [Votre mot de passe Docker Hub]
   - **ID** : `dockerhub-credentials`
   - **Description** : `Docker Hub dembouz7`
4. Cliquer sur **Create**

✅ **Credentials créés !**

---

### ✅ Étape 2 : Créer le Job Pipeline

#### 2.1 Créer un nouveau Job

1. Retourner au **Dashboard** (cliquer sur le logo Jenkins en haut à gauche)
2. Cliquer sur **Create a job** ou **New Item** (à gauche)
3. Remplir :
   - **Enter an item name** : `portfolio-cicd`
   - Sélectionner **Pipeline**
4. Cliquer sur **OK**

---

#### 2.2 Configurer le Job

##### Section "General"
1. ✅ Cocher **GitHub project**
2. **Project url** : `https://github.com/dembouz7/projet_fil_rouge`

##### Section "Build Triggers"
1. ✅ Cocher **GitHub hook trigger for GITScm polling**
   - Cela permet à GitHub de déclencher automatiquement le build via webhook

##### Section "Pipeline"
1. **Definition** : Sélectionner `Pipeline script from SCM`
2. **SCM** : Sélectionner `Git`
3. **Repository URL** : `https://github.com/dembouz7/projet_fil_rouge.git`
4. **Credentials** : Sélectionner `github-token` (celui créé à l'étape 1.1)
5. **Branches to build** :
   - **Branch Specifier** : `*/master` (ou `*/main` si votre branche principale est main)
6. **Script Path** : `Jenkinsfile` (laisser par défaut)

##### Section "Pipeline Syntax" (optionnel)
- Vous pouvez cliquer sur **Pipeline Syntax** pour générer des snippets de code

7. Cliquer sur **Save** en bas de la page

✅ **Job créé !**

---

### ✅ Étape 3 : Tester le Pipeline

#### 3.1 Lancer un Build Manuel

1. Sur la page du job `portfolio-cicd`
2. Cliquer sur **Build Now** (à gauche)
3. Un nouveau build apparaît dans **Build History**
4. Cliquer sur le numéro du build (ex: #1)
5. Cliquer sur **Console Output** pour voir les logs en temps réel

**Attendez que le build se termine...**

#### 3.2 Vérifier le Résultat

- ✅ **Bleu/Vert** = Succès
- ❌ **Rouge** = Échec
- ⚪ **Gris** = En cours ou annulé

Si le build échoue, vérifier les logs dans **Console Output**.

---

### ✅ Étape 4 : Configurer le Webhook GitHub (Optionnel)

**Note :** Cette étape nécessite que Jenkins soit accessible depuis Internet.

#### 4.1 Exposer Jenkins avec ngrok (si local)

```bash
# Installer ngrok : https://ngrok.com/download
ngrok http 8081
```

Copier l'URL générée (ex: `https://abc123.ngrok.io`)

#### 4.2 Ajouter le Webhook sur GitHub

1. Aller sur votre repository : `https://github.com/dembouz7/projet_fil_rouge`
2. Cliquer sur **Settings** → **Webhooks** → **Add webhook**
3. Remplir :
   - **Payload URL** : `https://abc123.ngrok.io/github-webhook/` (remplacer par votre URL)
   - **Content type** : `application/json`
   - **Which events** : `Just the push event`
   - ✅ **Active**
4. Cliquer sur **Add webhook**

#### 4.3 Tester le Webhook

```bash
# Faire un commit
git add .
git commit -m "Test Jenkins webhook"
git push origin master

# Jenkins devrait automatiquement lancer un build
```

---

## 🔧 Configuration Avancée (Optionnel)

### Installer des Plugins Supplémentaires

1. **Manage Jenkins** → **Manage Plugins**
2. Onglet **Available**
3. Chercher et installer :
   - **Blue Ocean** (interface moderne)
   - **Docker Pipeline** (si pas déjà installé)
   - **Slack Notification** (notifications Slack)
   - **Email Extension** (notifications email)
4. Cocher les plugins et cliquer sur **Install without restart**

### Configurer les Notifications Email

1. **Manage Jenkins** → **Configure System**
2. Section **E-mail Notification**
3. Remplir :
   - **SMTP server** : `smtp.gmail.com` (pour Gmail)
   - **SMTP Port** : `465`
   - ✅ **Use SSL**
   - **Username** : votre email
   - **Password** : mot de passe d'application Gmail
4. Cliquer sur **Test configuration** pour tester
5. Cliquer sur **Save**

### Voir l'Interface Blue Ocean

1. Cliquer sur **Open Blue Ocean** (à gauche)
2. Interface moderne et visuelle pour voir les pipelines

---

## 📊 Monitoring

### Voir les Builds

1. **Dashboard** → **portfolio-cicd**
2. Voir l'historique des builds
3. Statistiques :
   - Nombre de builds
   - Taux de succès
   - Durée moyenne

### Voir les Logs

1. Cliquer sur un build
2. **Console Output** : logs complets
3. **Pipeline Steps** : détails par étape

### Voir les Artefacts

Si vous configurez des artefacts dans le Jenkinsfile, ils apparaîtront ici.

---

## 🛠️ Dépannage Interface

### Build échoue avec "docker: command not found"

**Problème :** Jenkins ne peut pas accéder à Docker.

**Solution :**
```bash
# Arrêter Jenkins
docker stop jenkins
docker rm jenkins

# Redémarrer avec accès Docker
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Donner les permissions
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Credentials ne fonctionnent pas

1. Vérifier que l'ID est correct : `dockerhub-credentials` et `github-token`
2. Vérifier que les credentials sont dans le scope **Global**
3. Re-créer les credentials si nécessaire

### Webhook ne déclenche pas le build

1. Vérifier que **GitHub hook trigger for GITScm polling** est coché
2. Vérifier l'URL du webhook sur GitHub
3. Vérifier que Jenkins est accessible depuis Internet (ngrok)
4. Voir les logs du webhook sur GitHub : **Settings** → **Webhooks** → cliquer sur le webhook → **Recent Deliveries**

---

## ✅ Checklist de Configuration

### Credentials
- [ ] GitHub token créé et ajouté
- [ ] Docker Hub credentials ajoutés
- [ ] IDs corrects : `github-token` et `dockerhub-credentials`

### Job Pipeline
- [ ] Job `portfolio-cicd` créé
- [ ] Type : Pipeline
- [ ] GitHub project URL configurée
- [ ] GitHub hook trigger activé
- [ ] SCM : Git configuré
- [ ] Repository URL correcte
- [ ] Credentials GitHub sélectionnées
- [ ] Branch : `*/master` ou `*/main`
- [ ] Script Path : `Jenkinsfile`

### Test
- [ ] Build manuel lancé
- [ ] Build réussi (vert)
- [ ] Images sur Docker Hub
- [ ] Application déployée

### Webhook (Optionnel)
- [ ] ngrok installé et lancé (si local)
- [ ] Webhook GitHub configuré
- [ ] Test push déclenche le build

---

## 🎯 Résumé des URLs

| Service | URL | Description |
|---------|-----|-------------|
| Jenkins | http://localhost:8081 | Interface Jenkins |
| Blue Ocean | http://localhost:8081/blue | Interface moderne |
| GitHub | https://github.com/dembouz7/projet_fil_rouge | Repository |
| Docker Hub | https://hub.docker.com/u/dembouz7 | Images Docker |

---

## 📞 Support

### Problèmes courants

1. **Build échoue** → Voir **Console Output**
2. **Docker inaccessible** → Monter le socket Docker
3. **Credentials invalides** → Re-créer les credentials
4. **Webhook ne fonctionne pas** → Utiliser ngrok

### Logs Jenkins

```bash
# Voir les logs du container
docker logs -f jenkins

# Entrer dans le container
docker exec -it jenkins bash
```

---

**Configuration terminée ! Votre pipeline CI/CD est prêt ! 🚀**

**Prochaine étape :** Faire un commit et push pour tester le pipeline automatique.
