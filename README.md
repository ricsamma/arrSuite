# arrSuite

Stack de contenedores para ecosistema *arr* con red interna fija.

## Configuración global

- Red Docker interna: `arr-network` (`10.10.0.0/24`)
- Gateway: `10.10.0.1`
- Zona horaria: `America/Santiago`
- Usuario/grupo de ejecución:
	- `PUID=1000`
	- `PGID=10`

## Aplicaciones

### Sonarr

- Contenedor: `sonarr-samma`
- Imagen: `lscr.io/linuxserver/sonarr:latest`
- Puerto: `8989`
- IP interna: `10.10.0.10`
- Función: gestión y automatización de series.
- Volúmenes relevantes:
	- `/config`
	- `/data/downloads`
	- `/data/media/series`

### Radarr

- Contenedor: `radarr-samma`
- Imagen: `lscr.io/linuxserver/radarr:latest`
- Puerto: `7878`
- IP interna: `10.10.0.11`
- Función: gestión y automatización de películas.
- Volúmenes relevantes:
	- `/config`
	- `/data/downloads`
	- `/data/media/movies`

### Prowlarr

- Contenedor: `prowlarr-samma`
- Imagen: `lscr.io/linuxserver/prowlarr:latest`
- Puerto: `9696`
- IP interna: `10.10.0.12`
- Función: indexador central para Sonarr/Radarr/Lidarr.
- Volumen relevante:
	- `/config`

### qBittorrent

- Contenedor: `qbittorrent-samma`
- Imagen: `lscr.io/linuxserver/qbittorrent:latest`
- Puertos:
	- Web UI: `9865`
	- BitTorrent TCP/UDP: `6881`
- IP interna: `10.10.0.13`
- Función: cliente torrent para descargas automatizadas.
- Volúmenes relevantes:
	- `/config`
	- `/data/downloads`

### Lidarr

- Contenedor: `lidarr-samma`
- Imagen: `lscr.io/linuxserver/lidarr:latest`
- Puerto: `8686`
- IP interna: `10.10.0.14`
- Función: gestión y automatización de música.
- Volúmenes relevantes:
	- `/config`
	- `/data/downloads`
	- `/data/media/music`

### Jellyfin

- Contenedor: `jellyfin-samma`
- Imagen: `lscr.io/linuxserver/jellyfin:latest`
- Puertos:
	- HTTP: `8096`
	- HTTPS: `8920`
- IP interna: `10.10.0.15`
- Función: servidor multimedia para reproducción.
- Volúmenes relevantes:
	- `/config`
	- `/cache`
	- `/data/media/movies` (solo lectura)
	- `/data/media/series` (solo lectura)
	- `/data/media/music` (solo lectura)

### Jellyseerr

- Contenedor: `jellyseerr-samma`
- Imagen: `fallenbagel/jellyseerr:latest`
- Puerto: `5055`
- IP interna: `10.10.0.16`
- Función: solicitudes de contenido integradas con Jellyfin y apps *arr*.
- Volumen relevante:
	- `/app/config`

### NZBGet

- Contenedor: `nzbget-samma`
- Imagen: `lscr.io/linuxserver/nzbget:latest`
- Puerto: `6789`
- IP interna: `10.10.0.17`
- Función: cliente Usenet para descargas.
- Volúmenes relevantes:
	- `/config`
	- `/data/downloads`
- Solución de error común:
	- Si aparece `"/downloads/completed" directory does not exist`, NZBGet está usando una ruta antigua.
	- En `Settings > Paths`, define `MainDir` como `/data/downloads`.
	- Ajusta subcarpetas bajo `MainDir` (ejemplo):
		- `DestDir`: `${MainDir}/completed`
		- `InterDir`: `${MainDir}/intermediate`
		- `NzbDir`: `${MainDir}/nzb`
		- `QueueDir`: `${MainDir}/queue`
	- Crea esas carpetas en el host dentro de `/volume1/media/downloads` y reinicia el contenedor.

### Soulseek (slskd)

- Contenedor: `soulseek-samma`
- Imagen: `slskd/slskd:latest`
- Puertos:
	- Web UI: `5030`
	- Soulseek TCP/UDP: `50300`
- IP interna: `10.10.0.18`
- Función: cliente Soulseek para descubrimiento/descarga de música en red P2P.
- Volúmenes relevantes:
	- `/app` (configuración)
	- `/data/downloads`
	- `/data/media/music`

### Soularr

- Contenedor: `soularr-samma`
- Imagen: `mrusse08/soularr:latest`
- Puerto: no expone Web UI (servicio de automatización en segundo plano)
- IP interna: `10.10.0.19`
- Función: automatización sobre descargas de Soulseek.
- Volúmenes relevantes:
	- `/downloads`
	- `/data`

### aMule

- Contenedor: `amule-samma`
- Imagen: `ngosang/amule:latest`
- Puertos:
	- Web UI: `4711`
	- eD2k TCP: `4662`
	- Kad UDP: `4672`
- IP interna: `10.10.0.20`
- Función: cliente eD2k/Kad para búsqueda/descarga de contenido en esa red.
- Volúmenes relevantes:
	- `/config`
	- `/downloads`

## Checklist de configuración en las apps

### 1) Download clients

- En `qBittorrent` y `NZBGet`, confirma que la ruta de descarga activa sea: `/data/downloads`.
- En Sonarr/Radarr/Lidarr, agrega el download client por IP interna:
	- qBittorrent: `10.10.0.13:9865`
	- NZBGet: `10.10.0.17:6789`

### 2) Root folders

- Sonarr: `/data/media/series`
- Radarr: `/data/media/movies`
- Lidarr: `/data/media/music`

### 3) Verificación rápida

- En cada app *arr*, usa botón `Test` del download client.
- Si el test pide `Remote Path Mapping`, revisa que todas las rutas usen exactamente el mismo prefijo `/data/...`.
- Ejecuta una descarga de prueba y valida que haya import automático sin copia duplicada.

## Port forwarding en router local

Configura reglas NAT/Port Forwarding apuntando a la IP LAN del NAS (host Docker), usando el mismo puerto externo e interno salvo que necesites remapeo.

### Puertos que NO deberías abrir a Internet (solo LAN/VPN)

- Sonarr: `8989/TCP`
- Radarr: `7878/TCP`
- Prowlarr: `9696/TCP`
- qBittorrent WebUI: `9865/TCP`
- Lidarr: `8686/TCP`
- Jellyfin UI: `8096/TCP` (HTTP) y `8920/TCP` (HTTPS, opcional)
- Jellyseerr: `5055/TCP`
- NZBGet: `6789/TCP`
- Soulseek WebUI: `5030/TCP`
- aMule WebUI: `4711/TCP`
- Soularr: no expone puertos

### Puertos que SÍ conviene abrir (si buscas conectividad entrante)

- qBittorrent: `6881/TCP` y `6881/UDP`
- Soulseek (slskd): `50300/TCP` y `50300/UDP`
- aMule (eD2k/Kad): `4662/TCP` y `4672/UDP`

### Resumen rápido de reglas NAT recomendadas

- `6881/TCP` -> `IP_NAS:6881`
- `6881/UDP` -> `IP_NAS:6881`
- `50300/TCP` -> `IP_NAS:50300`
- `50300/UDP` -> `IP_NAS:50300`
- `4662/TCP` -> `IP_NAS:4662`
- `4672/UDP` -> `IP_NAS:4672`

### Recomendación de seguridad

- Para administración (UIs/APIs), evita abrir puertos a Internet.
- Usa VPN o reverse proxy con autenticación fuerte para acceso remoto.
- Abre en WAN solo los puertos P2P necesarios (`6881`, `50300`, `4662`, `4672`) si necesitas conectividad entrante óptima.

## Arranque del stack

```bash
docker compose up -d
```

## Acceso rápido (host local)

- Sonarr: `http://localhost:8989`
- Radarr: `http://localhost:7878`
- Prowlarr: `http://localhost:9696`
- qBittorrent: `http://localhost:9865`
- Lidarr: `http://localhost:8686`
- Jellyfin: `http://localhost:8096`
- Jellyseerr: `http://localhost:5055`
- NZBGet: `http://localhost:6789`
- Soulseek (slskd): `http://localhost:5030`
- aMule: `http://localhost:4711`
