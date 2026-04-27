# 🛡️ Tutoriel : Intégration CrowdSec + Traefik

Ce guide explique comment protéger ton serveur et tes sites web contre les bots et les attaques (comme les scans `/wp-config.php`).

## 1. Architecture
- **Traefik (Docker)** : Gère tes sites et écrit les logs d'accès.
- **CrowdSec (Serveur Host)** : Analyse les logs et bannit les IP malveillantes via le pare-feu (Firewall).

## 2. Configuration de Traefik
### 2.1 Préparation des fichiers de logs
Avant de lancer Traefik, il faut créer le fichier avec les bons droits :
```bash
mkdir -p /opt/traefik_master/logs && touch /opt/traefik_master/logs/access.log && chmod 666 /opt/traefik_master/logs/access.log
```

### 2.2 Configuration du `docker-compose.yml`
Les logs doivent être activés :
```yaml
command:
  - "--accesslog=true"
  - "--accesslog.filepath=/var/log/traefik/access.log"
  - "--accesslog.format=json"
volumes:
  - ./logs:/var/log/traefik:rw
```

### 2.3 Redémarrage de Traefik
```bash
cd /opt/traefik_master
docker compose up -d --force-recreate
```

## 3. Installation de CrowdSec (Hôte)
```bash
# Installation du moteur et du bouncer firewall
curl -s https://install.crowdsec.net | sudo sh
sudo apt-get install crowdsec crowdsec-firewall-bouncer-iptables -y

# Installation des collections recommandées (Traefik + Sécurité Générale)
sudo cscli collections install crowdsecurity/traefik \
                               crowdsecurity/http-cve \
                               crowdsecurity/whitelist-good-actors \
                               crowdsecurity/base-http-scenarios
```

## 4. Liaison des logs
Exécute cette commande pour dire à CrowdSec où trouver les logs de Traefik :
```bash
cat <<EOF | sudo tee /etc/crowdsec/acquis.yaml
filenames:
  - /opt/traefik_master/logs/access.log
labels:
  type: traefik
EOF
```

## 5. Console CrowdSec (Monitoring Web)
Pour visualiser tes blocages sur une interface web :
1. Crée un compte sur [app.crowdsec.net](https://app.crowdsec.net).
2. Lance la commande d'enrôlement :
   ```bash
   sudo cscli console enroll cmogund94000y02jvnqcyvp49
   ```
3. Retourne sur le site CrowdSec pour **accepter l'enrôlement**.
4. **Important :** Une fois accepté, recharge CrowdSec pour appliquer :
   ```bash
   sudo systemctl reload crowdsec
   ```

## 6. Commandes Utiles
- `sudo cscli decisions list` : Voir les IP actuellement bannies.
- `sudo cscli metrics` : Voir si les logs sont bien lus.
- `sudo cscli decisions delete --ip X.X.X.X` : Débannir une IP.
