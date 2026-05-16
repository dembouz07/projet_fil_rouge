# Diagnostic : Build Automatique ne Fonctionne Pas

## Étapes de Vérification

### 1. Vérifier la Configuration du Projet dans Jenkins

1. Ouvrez Jenkins : http://localhost:8081
2. Cliquez sur votre projet **portfolio-cicd**
3. Cliquez sur **Configure**
4. Allez dans la section **Build Triggers**
5. **Vérifiez que "Poll SCM" est coché**
6. Le champ Schedule doit contenir : `H/5 * * * *`
7. Cliquez sur **Save**

### 2. Vérifier les Logs de Polling Git

1. Sur la page du projet **portfolio-cicd**
2. Dans le menu de gauche, cliquez sur **Git Polling Log**
3. Vous devriez voir des entrées toutes les 5 minutes
4. Si vous voyez "No changes", c'est normal si vous n'avez pas fait de push
5. Si vous voyez des erreurs, notez-les

### 3. Forcer un Polling Immédiat

1. Sur la page du projet **portfolio-cicd**
2. Cliquez sur **Poll Now** (dans le menu de gauche)
3. Cela force Jenkins à vérifier immédiatement les changements Git

### 4. Tester avec un Vrai Push

```bash
# Faites un petit changement
echo "# Test auto-build" >> README.md

# Commitez
git add README.md
git commit -m "Test: declenchement automatique du build"

# Pushez
git push

# Attendez 5 minutes maximum et vérifiez Jenkins
```

### 5. Vérifier que Git est Accessible

Dans Jenkins, allez dans **Manage Jenkins** > **Configure System** > **Git**
- Vérifiez que Git est configuré
- Path to Git executable: `git` ou `C:\Program Files\Git\bin\git.exe`

## Problèmes Courants

### Problème 1 : Poll SCM n'est pas activé dans Jenkins UI

**Solution :**
1. Allez dans Configure du projet
2. Cochez "Poll SCM"
3. Entrez le schedule : `H/5 * * * *`
4. Save

### Problème 2 : Jenkins ne peut pas accéder au repository Git

**Solution :**
1. Vérifiez l'URL du repository dans Configure
2. Si repository local, utilisez le chemin absolu : `C:/laragon/www/projet_fil_rouge`
3. Si repository distant, vérifiez les credentials

### Problème 3 : Le schedule est mal configuré

**Syntaxe correcte :**
- `H/5 * * * *` = Toutes les 5 minutes
- `H/2 * * * *` = Toutes les 2 minutes
- `* * * * *` = Toutes les minutes (déconseillé)

### Problème 4 : Jenkins ne détecte pas les changements

**Solution :**
1. Vérifiez la branche configurée : `*/master` ou `*/main`
2. Vérifiez que vous pushez sur la bonne branche
3. Utilisez `git branch` pour voir votre branche actuelle

## Alternative : Webhook (Déclenchement Instantané)

Si le polling ne fonctionne pas ou si vous voulez un déclenchement instantané :

### Pour un Repository Local

Utilisez un hook Git post-commit :

1. Créez le fichier `.git/hooks/post-commit` :
```bash
#!/bin/bash
curl -X POST http://localhost:8081/job/portfolio-cicd/build?token=YOUR_TOKEN
```

2. Rendez-le exécutable :
```bash
chmod +x .git/hooks/post-commit
```

### Pour GitHub

1. Allez dans Settings > Webhooks de votre repo
2. Add webhook
3. URL : `http://VOTRE_IP:8081/github-webhook/`
4. Content type : `application/json`
5. Events : Just the push event

### Pour GitLab

1. Settings > Webhooks
2. URL : `http://VOTRE_IP:8081/project/portfolio-cicd`
3. Trigger : Push events

## Commandes de Diagnostic

```bash
# Vérifier l'état de Git
git status
git log --oneline -5

# Vérifier la branche
git branch

# Vérifier le remote
git remote -v

# Forcer un push
git push origin master --force
```

## Vérification Finale

Après avoir appliqué les corrections :

1. ✅ Poll SCM est activé dans Jenkins UI
2. ✅ Le schedule est `H/5 * * * *`
3. ✅ Git Polling Log montre des vérifications régulières
4. ✅ Un push déclenche un build dans les 5 minutes
5. ✅ Vous recevez un email de notification

## Si Rien ne Fonctionne

Essayez de recréer le projet :

1. Supprimez le projet actuel dans Jenkins
2. Créez un nouveau projet Pipeline
3. Configurez-le avec Poll SCM
4. Pointez vers votre Jenkinsfile
5. Lancez un premier build manuellement
6. Faites un push de test
