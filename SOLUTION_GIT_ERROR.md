# Solution : Erreur Git "fatal: not in a git directory"

## Problème

```
fatal: not in a git directory
hudson.plugins.git.GitException: Command "git config remote.origin.url" returned status code 128
```

## Cause

Le workspace Jenkins (`/var/jenkins_home/workspace/portfolio-cicd`) était corrompu ou incomplet.

## Solution Appliquée

### 1. Nettoyage du Workspace

```bash
docker exec jenkins rm -rf /var/jenkins_home/workspace/portfolio-cicd
```

Cela supprime le workspace corrompu pour permettre un clone frais.

### 2. Relancer le Build

**Option A : Manuellement dans Jenkins**
1. Allez sur http://localhost:8080/job/portfolio-cicd/
2. Cliquez sur **Build Now**
3. Jenkins va cloner le repository depuis zéro

**Option B : Via un nouveau push**
```bash
echo "# Force rebuild" >> README.md
git add README.md
git commit -m "Force: rebuild après nettoyage workspace"
git push origin master
```

## Vérification

Après le nettoyage, le prochain build devrait :
1. ✅ Cloner le repository avec succès
2. ✅ Exécuter tous les stages
3. ✅ Réussir le build complet

## Prévention

Ce problème peut arriver si :
- Le build précédent a été interrompu brutalement
- Le workspace a été modifié manuellement
- Il y a eu un problème réseau pendant le clone

**Solution préventive :**
Ajouter une option de nettoyage dans la configuration du projet :
1. Projet > Configure
2. Section "Pipeline"
3. Cocher "Lightweight checkout" (si disponible)

Ou ajouter dans le Jenkinsfile :
```groovy
options {
    skipDefaultCheckout()
}

stages {
    stage('Checkout') {
        steps {
            cleanWs()  // Nettoie le workspace avant chaque build
            checkout scm
        }
    }
    // ... autres stages
}
```

## Commandes Utiles

```bash
# Nettoyer le workspace
docker exec jenkins rm -rf /var/jenkins_home/workspace/portfolio-cicd

# Voir le contenu du workspace
docker exec jenkins ls -la /var/jenkins_home/workspace/

# Vérifier Git dans Jenkins
docker exec jenkins git --version

# Voir les logs Jenkins
docker logs jenkins

# Redémarrer Jenkins (si nécessaire)
docker restart jenkins
```

## Prochaine Action

**Relancez le build maintenant :**
1. Allez sur http://localhost:8080/job/portfolio-cicd/
2. Cliquez sur **Build Now**
3. Le build devrait réussir cette fois

Le workspace est maintenant propre et prêt pour un nouveau clone !
