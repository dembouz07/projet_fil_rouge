# Configuration Complète du Quality Gate SonarQube + Jenkins

## 📋 Vue d'ensemble

Le Quality Gate permet à Jenkins d'attendre que SonarQube termine son analyse et de vérifier si le code respecte les standards de qualité définis.

---

## 🔧 Étape 1: Configurer le Webhook SonarQube → Jenkins

### 1.1 Accéder à SonarQube
1. Ouvrez votre navigateur
2. Allez sur: **http://localhost:9000**
3. Connectez-vous:
   - **Username**: `admin`
   - **Password**: `admin123` (ou celui que vous avez défini)

### 1.2 Créer le Webhook
1. Dans le menu principal, cliquez sur **Administration** (en haut à droite)
2. Dans le menu de gauche, allez dans **Configuration** → **Webhooks**
3. Cliquez sur le bouton **Create** (en haut à droite)
4. Remplissez le formulaire:

   ```
   Name: Jenkins
   URL: http://jenkins:8080/sonarqube-webhook/
   Secret: (laissez vide)
   ```

   **⚠️ IMPORTANT**: 
   - Utilisez `http://jenkins:8080` (nom du conteneur) et NON `http://localhost:8080`
   - N'oubliez pas le `/` à la fin de `/sonarqube-webhook/`

5. Cliquez sur **Create**

### 1.3 Vérifier le Webhook
Vous devriez voir le webhook dans la liste avec:
- ✅ Nom: Jenkins
- ✅ URL: http://jenkins:8080/sonarqube-webhook/
- ✅ Status: Actif

---

## 🔧 Étape 2: Vérifier la Configuration Jenkins

### 2.1 Vérifier le Plugin SonarQube Scanner
1. Ouvrez Jenkins: **http://localhost:8080**
2. Allez dans **Manage Jenkins** → **Manage Plugins**
3. Onglet **Installed plugins**
4. Recherchez: `SonarQube Scanner`
5. ✅ Il devrait être installé (version 2.x ou supérieure)

### 2.2 Vérifier la Configuration du Serveur SonarQube
1. **Manage Jenkins** → **Configure System**
2. Descendez jusqu'à la section **SonarQube servers**
3. Vérifiez que vous avez:
   - ✅ **Name**: `SonarQube`
   - ✅ **Server URL**: `http://sonarqube:9000`
   - ✅ **Server authentication token**: Configuré avec votre token

### 2.3 Vérifier SonarQube Scanner Tool
1. **Manage Jenkins** → **Global Tool Configuration**
2. Descendez jusqu'à **SonarQube Scanner**
3. Vérifiez:
   - ✅ **Name**: `SonarQube Scanner`
   - ✅ **Install automatically**: Coché
   - ✅ **Version**: SonarQube Scanner (dernière version)

---

## 🔧 Étape 3: Modifier le Jenkinsfile

### 3.1 Ouvrir le Fichier
Ouvrez le fichier `Jenkinsfile` à la racine de votre projet.

### 3.2 Remplacer le Stage Quality Gate

**Trouvez cette section:**
```groovy
stage('Quality Gate') {
    steps {
        script {
            // Désactivé temporairement - SonarQube prend trop de temps
            echo 'Quality Gate check skipped - check results manually at http://localhost:9000'
            // timeout(time: 10, unit: 'MINUTES') {
            //     waitForQualityGate abortPipeline: true
            // }
        }
    }
}
```

**Remplacez par:**
```groovy
stage('Quality Gate') {
    steps {
        timeout(time: 10, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

### 3.3 Sauvegarder et Commiter
```bash
git add Jenkinsfile
git commit -m "Enable Quality Gate with SonarQube webhook"
git push origin master
```

---

## 🧪 Étape 4: Tester la Configuration

### 4.1 Déclencher un Build
Le webhook GitHub devrait déclencher automatiquement un build, ou vous pouvez:
1. Aller sur Jenkins: http://localhost:8080
2. Cliquer sur votre projet **portfolio-cicd**
3. Cliquer sur **Build Now**

### 4.2 Observer le Build
1. Cliquez sur le numéro du build (ex: #25)
2. Cliquez sur **Console Output**
3. Observez le stage **Quality Gate**:

**Comportement attendu:**
```
[Pipeline] stage
[Pipeline] { (Quality Gate)
[Pipeline] timeout
Timeout set to expire in 10 min 0 sec
[Pipeline] {
[Pipeline] waitForQualityGate
Checking status of SonarQube task 'AZ5...' on server 'SonarQube'
SonarQube task 'AZ5...' status is 'SUCCESS'
Quality Gate passed
[Pipeline] }
[Pipeline] // timeout
[Pipeline] }
[Pipeline] // stage
```

### 4.3 Vérifier dans SonarQube
1. Ouvrez SonarQube: http://localhost:9000
2. Allez dans **Administration** → **Configuration** → **Webhooks**
3. Cliquez sur votre webhook **Jenkins**
4. Cliquez sur **Recent Deliveries**
5. Vous devriez voir les requêtes envoyées avec:
   - ✅ Status: 200 OK
   - ✅ Payload envoyé à Jenkins

---

## 🎯 Étape 5: Comprendre le Quality Gate

### 5.1 Que Vérifie le Quality Gate?

Par défaut, SonarQube vérifie:
- 🐛 **Bugs**: Pas de nouveaux bugs
- 🔒 **Vulnerabilities**: Pas de nouvelles vulnérabilités
- 🧹 **Code Smells**: Ratio de dette technique acceptable
- 📊 **Coverage**: Couverture de tests (si configurée)
- 🔄 **Duplications**: Taux de duplication acceptable

### 5.2 Voir les Résultats
1. Ouvrez SonarQube: http://localhost:9000
2. Cliquez sur votre projet **Portfolio CI/CD**
3. Vous verrez:
   - **Quality Gate Status**: PASSED ou FAILED
   - **Bugs**: Nombre de bugs détectés
   - **Vulnerabilities**: Nombre de vulnérabilités
   - **Code Smells**: Nombre de mauvaises pratiques
   - **Coverage**: Pourcentage de couverture de tests
   - **Duplications**: Pourcentage de code dupliqué

### 5.3 Personnaliser le Quality Gate (Optionnel)
1. Dans SonarQube, allez dans **Quality Gates**
2. Cliquez sur **Sonar way** (le Quality Gate par défaut)
3. Vous pouvez:
   - Créer un nouveau Quality Gate
   - Modifier les seuils (ex: 80% de couverture minimum)
   - Ajouter de nouvelles conditions

---

## ⚠️ Troubleshooting

### Problème 1: Quality Gate Timeout
**Symptôme**: Le build échoue avec "Timeout has been exceeded"

**Solutions**:
1. Augmenter le timeout dans le Jenkinsfile:
   ```groovy
   timeout(time: 15, unit: 'MINUTES') {
       waitForQualityGate abortPipeline: true
   }
   ```

2. Vérifier que le webhook est bien configuré dans SonarQube

### Problème 2: Webhook ne fonctionne pas
**Symptôme**: SonarQube n'envoie pas de notification à Jenkins

**Solutions**:
1. Vérifier l'URL du webhook: `http://jenkins:8080/sonarqube-webhook/`
2. Vérifier que Jenkins et SonarQube sont sur le même réseau Docker:
   ```bash
   docker network inspect portfolio-network
   ```
3. Tester la connectivité:
   ```bash
   docker exec sonarqube curl -v http://jenkins:8080/sonarqube-webhook/
   ```

### Problème 3: Quality Gate échoue toujours
**Symptôme**: Le Quality Gate est toujours en FAILED

**Solutions**:
1. Consultez les résultats dans SonarQube pour voir les problèmes
2. Corrigez les bugs/vulnérabilités critiques
3. Ou désactivez temporairement certaines règles:
   - Dans SonarQube: **Quality Gates** → Modifier les seuils

### Problème 4: "Unable to find SonarQube task"
**Symptôme**: Jenkins ne trouve pas la tâche SonarQube

**Solutions**:
1. Vérifiez que l'analyse SonarQube s'est bien terminée avant le Quality Gate
2. Vérifiez les logs du stage "SonarQube Analysis"
3. Assurez-vous que le rapport a bien été envoyé:
   ```
   Analysis report uploaded in XXXms
   ANALYSIS SUCCESSFUL
   ```

---

## 📊 Résultat Final

Une fois configuré correctement, votre pipeline:

1. ✅ Clone le code depuis GitHub
2. ✅ Lance l'analyse SonarQube
3. ✅ **Attend que SonarQube termine et vérifie le Quality Gate**
4. ✅ Si Quality Gate PASSED → Continue le build
5. ❌ Si Quality Gate FAILED → Arrête le pipeline
6. ✅ Build les images Docker
7. ✅ Push vers Docker Hub
8. ✅ Déploie l'application

---

## 🎓 Commandes Utiles

### Vérifier les logs SonarQube
```bash
docker logs sonarqube --tail 50
```

### Vérifier les logs Jenkins
```bash
docker logs jenkins --tail 50
```

### Tester le webhook manuellement
```bash
docker exec jenkins curl -X POST http://jenkins:8080/sonarqube-webhook/ \
  -H "Content-Type: application/json" \
  -d '{"status":"SUCCESS"}'
```

### Redémarrer les services
```bash
# Redémarrer SonarQube
docker restart sonarqube

# Redémarrer Jenkins
docker restart jenkins
```

---

## ✅ Checklist de Vérification

Avant de considérer la configuration comme terminée, vérifiez:

- [ ] Le webhook est créé dans SonarQube
- [ ] L'URL du webhook est `http://jenkins:8080/sonarqube-webhook/`
- [ ] Le plugin SonarQube Scanner est installé dans Jenkins
- [ ] Le serveur SonarQube est configuré dans Jenkins
- [ ] Le Jenkinsfile contient le stage Quality Gate activé
- [ ] Un build de test a réussi avec le Quality Gate
- [ ] Les "Recent Deliveries" du webhook montrent des requêtes réussies (200 OK)

---

**Votre Quality Gate est maintenant configuré et fonctionnel!** 🎉
