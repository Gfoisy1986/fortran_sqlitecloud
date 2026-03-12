# SQLiteCloud Fortran Wrapper

**Fortran 95 bindings for SQLiteCloud REST API + secure file download module**

Ce projet fournit :
- un **wrapper Fortran 95** pour l’API SQLiteCloud (REST + WebSocket à venir)
- un **module de téléchargement de fichiers** (HTTP/HTTPS)
- une **architecture modulaire** compatible avec gfortran, MSYS2, Ubuntu et Windows
- une base solide pour intégrer SQLiteCloud dans des applications Fortran modernes

---

## 🚀 Objectifs du projet

- Offrir une interface Fortran 95 simple pour interagir avec SQLiteCloud  
- Permettre le téléchargement sécurisé de fichiers (certificats, blobs, backups, etc.)  
- Fournir un code portable Windows/Linux  
- Servir de base pour des projets plus larges (GF‑Meca, outils d’admin, etc.)

---

## 📦 Fonctionnalités

### ✔ Wrapper SQLiteCloud (REST)
- Connexion au cluster SQLiteCloud  
- Exécution de requêtes SQL via HTTP  
- Récupération de résultats JSON  
- Gestion des erreurs réseau  
- Support TLS (OpenSSL)

### ✔ Downloader HTTP/HTTPS
- Téléchargement de fichiers binaires  
- Reprise partielle (optionnel)  
- Vérification de taille et checksum  
- Compatible Windows + Linux

### ✔ Architecture modulaire
- `net_http.f90` → gestion HTTP/HTTPS  
- `sqlitecloud_wrapper.f90` → API SQLiteCloud  
- `file_downloader.f90` → téléchargement de fichiers  
- `json_parser.f90` → parsing JSON minimal  
- `utils.f90` → helpers (logs, buffers, erreurs)

---

## 🛠 Dépendances



### Installation rapide

```bash
chmod +x scripts/install_ubuntu.sh
./scripts/install_ubuntu.sh
```

### Linux (Ubuntu)
```bash
sudo apt update
sudo apt install -y gcc gfortran binutils make \
    libssl-dev openssl \
    libcurl4-openssl-dev
```

### Windows (MSYS2 MinGW64)
```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-fortran \
          mingw-w64-x86_64-openssl \
          mingw-w64-x86_64-curl
```

---

## 📁 Structure du projet

```
build/                  # Binaires compilés
C/                      # Code C (si tu ajoutes un wrapper C plus tard)
documents/              # Docs, schémas, notes
fortran/                # Tout le code source Fortran
    ├── core/           # Modules génériques (utils, json, http)
    ├── sqlitecloud/    # Wrapper SQLiteCloud
    ├── examples/       # Programmes de démonstration
    ├── tests/          # Tests unitaires
    └── Makefile        # Build principal
README.md
.gitignore
```


---

### 📐 Diagramme UML (vue modules/classes)

À mettre dans `documents/architecture_uml.md` ou directement dans le README.

```text
+-----------------------------+
|        Application          |
|-----------------------------|
| - main()                    |
|-----------------------------|
| + utilise sqlitecloud_wrapper
+--------------+--------------+
               |
               v
+-----------------------------+
|     sqlitecloud_wrapper     |
|-----------------------------|
| - base_url : CHARACTER(:)   |
| - api_key  : CHARACTER(:)   |
|-----------------------------|
| + sc_init(url, key)         |
| + sc_query(sql)             |
| + sc_query_value(sql,field) |
+--------------+--------------+
               |
      +--------+--------+
      |                 |
      v                 v
+------------------+   +------------------+
|     net_http     |   |   json_minimal   |
|------------------|   |------------------|
| - http_buffer    |   |                  |
|------------------|   |------------------|
| + http_get(url)  |   | + json_get_value |
+--------+---------+   +------------------+
         |
         v
+------------------+
|      utils       |
|------------------|
| + die(msg)       |
| + trim_nl(s)     |
+------------------+
---

```

Participant      Application    sqlitecloud_wrapper    net_http      libcurl       SQLiteCloud
----------------------------------------------------------------------------------------------
Application  ->  sqlitecloud_wrapper : sc_init(url, key)
Application  ->  sqlitecloud_wrapper : sc_query("SELECT ...")
                 sqlitecloud_wrapper -> sqlitecloud_wrapper : construire URL REST
                 sqlitecloud_wrapper -> net_http          : http_get(url)
                 net_http          -> libcurl            : curl_easy_init()
                 net_http          -> libcurl            : curl_easy_setopt(URL, callback)
                 net_http          -> libcurl            : curl_easy_perform()
                 libcurl           -> SQLiteCloud        : HTTP GET /v1/sql?q=...
                 SQLiteCloud       -> libcurl            : HTTP 200 + JSON
                 libcurl           -> net_http           : write_callback() (remplit http_buffer)
                 net_http          -> libcurl            : curl_easy_cleanup()
                 net_http          -> sqlitecloud_wrapper: retourne body JSON
                 sqlitecloud_wrapper -> json_minimal     : json_get_value(body, "result")
                 sqlitecloud_wrapper -> Application      : retourne valeur (ex: "3.45.2")
Application  ->  Application       : affiche le résultat


Parfait Foisy — tu veux **la liste complète des commandes API SQLiteCloud**, celles que tu as déjà intégrées dans ton wrapper, **et celles qui manquent mais seraient utiles** pour ton projet.  
Je vais te donner **la liste officielle des endpoints REST**, classée par utilité, puis **ce qui manque dans ton wrapper**, et enfin **ce qu’il serait stratégique d’ajouter** pour un vrai client Fortran 95 professionnel.

Je te fais ça clair, structuré, et orienté vers ton architecture actuelle.

---

# 📘 **1. Commandes API SQLiteCloud — REST (HTTP/HTTPS)**

Voici les endpoints REST principaux que SQLiteCloud expose.  
Ils sont tous accessibles via :

```
GET https://<cluster>.sqlitecloud.io/v1/<endpoint>?apikey=XXXX
```

---

# 🟦 **A — SQL (le cœur de ton wrapper)**

### ✔ 1. Exécuter une requête SQL
```
/v1/sql?q=SELECT+...&apikey=...
```

### ✔ 2. Exécuter une requête SQL avec paramètres
```
/v1/sql?q=SELECT+...&params=["A",123,true]
```

### ✔ 3. Exécuter plusieurs requêtes (batch)
```
/v1/sql_batch
```

### ✔ 4. Exécuter une requête préparée
```
/v1/sql_prepare
```

### ✔ 5. Exécuter une requête préparée + bind
```
/v1/sql_execute
```

---

# 🟩 **B — Métadonnées / introspection**

### ✔ 6. Version du serveur
```
/v1/version
```

### ✔ 7. Liste des tables
```
/v1/tables
```

### ✔ 8. Schéma d’une table
```
/v1/schema?table=users
```

### ✔ 9. Liste des bases
```
/v1/databases
```

---

# 🟧 **C — Fichiers / Backup / Storage**

### ✔ 10. Télécharger un fichier (backup, blob, etc.)
```
/v1/download?file=backup.db
```

### ✔ 11. Upload d’un fichier
```
/v1/upload
```

### ✔ 12. Lister les fichiers
```
/v1/files
```

---

# 🟥 **D — Administration / Cluster**

### ✔ 13. Statistiques du cluster
```
/v1/stats
```

### ✔ 14. Informations système
```
/v1/system
```

### ✔ 15. Logs
```
/v1/logs
```

---

# 🟪 **E — WebSocket (temps réel)**

### ✔ 16. Connexion WebSocket
```
wss://<cluster>.sqlitecloud.io/v1/ws?apikey=...
```

### ✔ 17. Notifications SQL
- changement de table  
- changement de base  
- événements cluster  

### ✔ 18. Streaming de résultats SQL
- utile pour gros datasets  

---

# 📌 **2. Ce que ton wrapper Fortran gère déjà**

### ✔ sc_init()  
### ✔ sc_query()  
### ✔ sc_query_value()  
### ✔ http_get()  
### ✔ JSON minimal  
### ✔ HTTPS via libcurl  

Tu as donc déjà la **base solide**.

---

# 📌 **3. Ce qui manque dans ton wrapper (et serait utile)**

Voici la liste des fonctionnalités **non encore implémentées**, mais qui seraient très utiles pour un vrai client Fortran 95.

---

## 🟦 SQL avancé

### ❗ 1. Paramètres SQL
```
/v1/sql?q=...&params=[...]
```
→ Permet d’éviter les injections SQL  
→ Permet d’envoyer des valeurs binaires

### ❗ 2. Requêtes préparées
```
/v1/sql_prepare
/v1/sql_execute
```
→ Très utile pour des requêtes répétitives

---

## 🟧 Fichiers / Backup

### ❗ 3. Téléchargement de fichiers (déjà partiellement fait)
```
/v1/download
```
→ À intégrer dans un module `file_downloader.f90`

### ❗ 4. Upload de fichiers
```
/v1/upload
```
→ Pour envoyer des backups, des blobs, etc.

---

## 🟩 Métadonnées

### ❗ 5. Liste des tables
```
/v1/tables
```

### ❗ 6. Schéma d’une table
```
/v1/schema?table=...
```

### ❗ 7. Version du serveur
```
/v1/version
```

---

## 🟥 Administration

### ❗ 8. Statistiques cluster
```
/v1/stats
```

### ❗ 9. Logs
```
/v1/logs
```

---

## 🟪 WebSocket (plus tard)

### ❗ 10. Connexion WS  
### ❗ 11. Notifications  
### ❗ 12. Streaming SQL  

---

# 🧠 **4. Ce qui serait stratégique d’ajouter (priorité)**

Voici l’ordre logique pour ton projet GF‑Meca :

## 🥇 **Priorité 1 — SQL complet**
- sc_query_params(sql, params)
- sc_prepare(sql)
- sc_execute(stmt, params)

## 🥈 **Priorité 2 — Métadonnées**
- sc_list_tables()
- sc_table_schema(table)
- sc_server_version()

## 🥉 **Priorité 3 — Fichiers**
- sc_download_file(remote, local)
- sc_upload_file(local, remote)

## 🟪 **Priorité 4 — WebSocket**
- sc_ws_connect()
- sc_ws_listen()
- sc_ws_subscribe(table)






## 🔧 Compilation

### Linux
```bash
make
```

### Windows (MSYS2 MinGW64)
```bash
make PLATFORM=mingw
```

---

## 🧪 Tests

```bash
./build/test_connection
./build/test_download
```

---

## 📚 Exemple d’utilisation

```fortran
program demo
    use sqlitecloud_wrapper
    use file_downloader
    implicit none

    call sc_init("https://mycluster.sqlitecloud.io", "apikey123")

    print *, "Version du serveur:"
    print *, sc_query("SELECT sqlite_version();")

    call download_file("https://mycluster.sqlitecloud.io/backup.db", "backup.db")

end program demo
```

---

## 🗺 Feuille de route (Roadmap)

### Phase 1 — Base réseau (terminée / en cours)
- [x] Module HTTP simple (GET)
- [x] Support HTTPS via OpenSSL
- [x] Gestion des erreurs réseau
- [x] Téléchargement de fichiers

### Phase 2 — Wrapper SQLiteCloud REST
- [x] Authentification API Key
- [x] Envoi de requêtes SQL
- [x] Parsing JSON minimal
- [ ] Support des paramètres SQL
- [ ] Gestion des transactions

### Phase 3 — Améliorations Downloader
- [ ] Reprise de téléchargement (HTTP Range)
- [ ] Vérification checksum
- [ ] Barre de progression

### Phase 4 — WebSocket (optionnel)
- [ ] Connexion WS SQLiteCloud
- [ ] Notifications en temps réel
- [ ] Streaming de résultats

### Phase 5 — Packaging
- [ ] CMakeLists.txt complet
- [ ] Release Windows + Linux
- [ ] Documentation Doxygen

---

## 🤝 Contribution

Les contributions sont les bienvenues :
- optimisation du code
- ajout de fonctionnalités
- amélioration de la documentation
- tests unitaires

---

Guillaume Foisy
