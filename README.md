# Traefik Master

Ce dépôt contient la configuration centrale de Traefik pour la gestion du reverse proxy et des certificats SSL (Let's Encrypt).

Il utilise un réseau Docker partagé nommé `proxy_net` pour communiquer avec les autres services.

## Installation Rapide

Pour installer Traefik Master sur votre serveur, exécutez la commande suivante :

```bash
curl -fsSL https://raw.githubusercontent.com/geonidas6/traefik_master/main/install.sh | sudo bash
```

## Structure du Projet

- `docker-compose.yml` : Configuration des services Traefik.
- `letsencrypt/` : Répertoire stockant les certificats SSL.
- `.env` : Fichier de configuration pour l'email ACME.

## Utilisation

Une fois installé, Traefik Master tournera en arrière-plan. Vous pouvez connecter vos autres services en les ajoutant au réseau `proxy_net` et en utilisant les labels Traefik appropriés.

### Exemple de labels pour un service client :

```yaml
services:
  mon-app:
    networks:
      - proxy_net
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mon-app.rule=Host(`mon-app.exemple.com`)"
      - "traefik.http.routers.mon-app.entrypoints=websecure"
      - "traefik.http.routers.mon-app.tls.certresolver=myresolver"

networks:
  proxy_net:
    external: true
```

## Logs

Pour voir les logs de Traefik :

```bash
cd /opt/traefik_master
docker compose logs -f
```
