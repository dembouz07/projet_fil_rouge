# SonarQube Network Connectivity Fix

## Problem
Jenkins pipeline was failing at the SonarQube Analysis stage with the error:
```
ERROR Failed to query server version: Call to URL [http://sonarqube:9000/api/v2/analysis/version] failed: null
```

## Root Cause
- Jenkins container was running on the default `bridge` network
- SonarQube container was running on `projet_fil_rouge_sonarqube-network`
- The `portfolio-network` referenced in `docker-compose.sonarqube.yml` didn't exist
- Containers on different networks cannot communicate with each other

## Solution Applied

### 1. Created the portfolio-network
```bash
docker network create portfolio-network
```

### 2. Connected Jenkins to portfolio-network
```bash
docker network connect portfolio-network jenkins
```

### 3. Connected SonarQube to portfolio-network
```bash
docker network connect portfolio-network sonarqube
```

### 4. Restarted Jenkins
```bash
docker restart jenkins
```
This ensures Jenkins properly recognizes the new network configuration.

## Verification

### Test connectivity from Jenkins to SonarQube:
```bash
docker exec jenkins curl -s http://sonarqube:9000/api/system/status
```

**Expected output:**
```json
{"id":"9B767396-AZ5zDC-gMZ3P1o9Rl8sO","version":"9.9.8.100196","status":"UP"}
```

### Check network configuration:
```bash
docker network inspect portfolio-network
```

**Expected:** Both `jenkins` and `sonarqube` containers should be listed in the "Containers" section.

## Next Steps

1. **Wait for Jenkins SCM polling** (every 5 minutes) to detect the latest commit
2. **Or manually trigger a build** in Jenkins UI
3. **Monitor the build** to ensure SonarQube Analysis stage completes successfully
4. **Check SonarQube dashboard** at http://localhost:9000 for analysis results

## Important Notes

- Both containers must be on the same Docker network for DNS resolution to work
- Jenkins uses the container name `sonarqube` as the hostname (not `localhost`)
- After network changes, always restart Jenkins to apply the configuration
- The network connection persists across container restarts

## Troubleshooting

If the issue persists:

1. **Verify both containers are running:**
   ```bash
   docker ps | grep -E "jenkins|sonarqube"
   ```

2. **Check if containers are on the same network:**
   ```bash
   docker network inspect portfolio-network
   ```

3. **Test DNS resolution from Jenkins:**
   ```bash
   docker exec jenkins ping -c 3 sonarqube
   ```

4. **Check SonarQube is accessible:**
   ```bash
   docker exec jenkins curl -v http://sonarqube:9000
   ```

## Files Modified
- `sonar-project.properties` - Added comments documenting the network fix

## Status
✅ Network connectivity established
✅ Jenkins can reach SonarQube
⏳ Waiting for next Jenkins build to verify full integration
