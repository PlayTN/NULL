# PROMPT COMPLETO - SEZIONE 1: Setup Base Backend NULL

## CONTESTO DEL PROGETTO

Stai sviluppando il backend per **NULL** (UrbanLock), un sistema di smart locker modulari per smart city. Il frontend Flutter è già sviluppato e si aspetta un'API REST con le seguenti caratteristiche:

- **Base URL**: `https://api.null.app` (configurabile via env)
- **API Version**: `v1`
- **Formato**: JSON
- **Autenticazione**: JWT Bearer Token (da implementare nella Sezione 2)
- **Timeout**: 30 secondi

Il progetto usa **MongoDB** come database (collezioni già esistenti: utente, locker, cella, noleggio, donazione, segnalazione, allarme, sensore, lettura_sensore, operatore, audit_operatore).

## OBIETTIVO SEZIONE 1

Configurare l'infrastruttura base del backend Node.js con:
1. Server Express.js funzionante
2. Connessione MongoDB configurata
3. Supporto TLS/HTTPS
4. Struttura progetto organizzata
5. Gestione errori centralizzata
6. Health check endpoint
7. Configurazione ambiente (variabili env)
8. CORS configurato per frontend Flutter

## STACK TECNOLOGICO RICHIESTO

- **Node.js**: v18 o superiore
- **Express.js**: v4.18+
- **Mongoose**: v7+ (driver MongoDB)
- **dotenv**: Per variabili ambiente
- **helmet**: Per sicurezza HTTP headers
- **cors**: Per Cross-Origin Resource Sharing
- **express-validator**: Per validazione (preparazione futura)
- **winston**: Per logging (opzionale, ma consigliato)
- **https**: Modulo nativo Node.js per TLS

## STRUTTURA FILE DA CREARE

Crea la seguente struttura nella cartella `backend/`:

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js          # Connessione MongoDB
│   │   ├── tls.js               # Configurazione TLS/HTTPS
│   │   └── env.js               # Validazione variabili ambiente
│   ├── middleware/
│   │   ├── errorHandler.js     # Gestione errori centralizzata
│   │   └── notFound.js          # Handler route non trovate
│   ├── routes/
│   │   └── health.js            # Route health check
│   ├── utils/
│   │   └── logger.js            # Logger (se usi winston)
│   └── server.js                # Entry point principale
├── certificates/                # Cartella per certificati TLS (gitignored)
│   ├── .gitkeep
│   └── README.md                # Istruzioni per certificati
├── uploads/                      # Cartella per file upload (gitignored)
│   └── .gitkeep
├── .env.example                  # Template variabili ambiente
├── .env                          # File env reale (gitignored)
├── .gitignore                    # Git ignore
├── package.json                  # Dipendenze e scripts
└── README.md                     # Documentazione setup
```

## DETTAGLI IMPLEMENTAZIONE

### 1. package.json

Crea `package.json` con:
- **name**: "null-backend"
- **version**: "1.0.0"
- **description**: "Backend API per sistema smart locker NULL"
- **main**: "src/server.js"
- **type**: "module" (per usare ES6 modules)
- **scripts**:
  - `"start"`: "node src/server.js"
  - `"dev"`: "node --watch src/server.js" (o usa nodemon se preferisci)
  - `"test"`: "echo 'Tests da implementare'"
- **dependencies**: express, mongoose, dotenv, helmet, cors, express-validator, winston
- **devDependencies**: (opzionale: nodemon per sviluppo)

### 2. .env.example

Crea template con variabili:
```env
# Server
NODE_ENV=development
PORT=3000
HTTPS_PORT=3443

# MongoDB
MONGODB_URI=mongodb://localhost:27017/null
MONGODB_URI_PROD=mongodb+srv://user:password@cluster.mongodb.net/null

# TLS/SSL
TLS_ENABLED=true
TLS_KEY_PATH=./certificates/key.pem
TLS_CERT_PATH=./certificates/cert.pem

# API
API_VERSION=v1
API_BASE_URL=https://api.null.app

# CORS
CORS_ORIGIN=http://localhost:3000,https://localhost:8080

# Logging
LOG_LEVEL=info
```

### 3. src/config/env.js

Crea validazione variabili ambiente:
- Leggi `.env` con `dotenv`
- Valida presenza variabili obbligatorie:
  - `MONGODB_URI` (o `MONGODB_URI_PROD` in produzione)
  - `PORT` o `HTTPS_PORT`
- Fornisce valori di default per sviluppo
- Esporta oggetto config con tutte le variabili

### 4. src/config/database.js

Configura connessione MongoDB:
- Usa Mongoose per connettere
- Connection string da `MONGODB_URI` o `MONGODB_URI_PROD`
- Gestisci eventi:
  - `connected`: log successo
  - `error`: log errore
  - `disconnected`: log disconnessione
- Opzioni connessione:
  - `useNewUrlParser: true`
  - `useUnifiedTopology: true`
  - Timeout configurabile
- Esporta funzione `connectDB()` e `disconnectDB()`

### 5. src/config/tls.js

Configurazione TLS/HTTPS:
- Se `TLS_ENABLED=true`, carica certificati da:
  - `TLS_KEY_PATH` (chiave privata)
  - `TLS_CERT_PATH` (certificato)
- Gestisci errori se certificati non trovati (log warning, ma non bloccare)
- In sviluppo, se certificati non presenti, genera self-signed (opzionale)
- Esporta oggetto `tlsOptions` con `key` e `cert`
- Esporta funzione helper per verificare esistenza certificati

### 6. src/utils/logger.js (opzionale ma consigliato)

Configura Winston logger:
- Livelli: error, warn, info, debug
- Formato: timestamp + livello + messaggio
- Output: console in sviluppo, file in produzione (opzionale)
- Colori per console in sviluppo

### 7. src/middleware/errorHandler.js

Middleware gestione errori Express:
- Catch tutti gli errori non gestiti
- Formato risposta JSON standard:
  ```json
  {
    "success": false,
    "error": {
      "message": "Messaggio errore",
      "code": "ERROR_CODE",
      "statusCode": 500
    }
  }
  ```
- Gestisci diversi tipi errori:
  - ValidationError (400)
  - UnauthorizedError (401)
  - NotFoundError (404)
  - Generic Error (500)
- Log errore completo (stack trace in sviluppo)

### 8. src/middleware/notFound.js

Middleware per route non trovate:
- Risponde con JSON:
  ```json
  {
    "success": false,
    "error": {
      "message": "Route not found",
      "code": "NOT_FOUND",
      "statusCode": 404
    }
  }
  ```

### 9. src/routes/health.js

Route health check:
- `GET /health` o `GET /api/v1/health`
- Risposta JSON:
  ```json
  {
    "success": true,
    "status": "ok",
    "timestamp": "2025-01-XX...",
    "uptime": 12345,
    "database": "connected",
    "version": "1.0.0"
  }
  ```
- Verifica connessione MongoDB
- Calcola uptime server

### 10. src/server.js

Entry point principale:
- Importa tutte le configurazioni
- Crea app Express
- Configura middleware:
  - `helmet()` per sicurezza headers
  - `cors()` con origine da `CORS_ORIGIN`
  - `express.json()` per parsing JSON
  - `express.urlencoded({ extended: true })`
- Connette MongoDB (chiama `connectDB()`)
- Monta route:
  - `/health` → health route
  - `/api/v1/health` → health route (alternativa)
- Aggiungi middleware `notFound` (dopo tutte le route)
- Aggiungi middleware `errorHandler` (ultimo)
- Avvia server:
  - Se TLS abilitato: server HTTPS
  - Altrimenti: server HTTP
- Gestisci shutdown graceful (SIGTERM, SIGINT):
  - Chiudi connessione MongoDB
  - Chiudi server
- Log messaggio avvio con porta e ambiente

## CONFIGURAZIONE CORS

Configura CORS per permettere richieste dal frontend Flutter:
- Origins: da variabile `CORS_ORIGIN` (split per multipli)
- Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS
- Headers: Content-Type, Authorization
- Credentials: true (per JWT in futuro)

## GESTIONE CERTIFICATI TLS

Nella cartella `certificates/`:
- Crea `README.md` con istruzioni:
  - Per sviluppo: come generare self-signed certificate
  - Per produzione: dove ottenere certificati reali (Let's Encrypt, etc.)
- Esempio comando per self-signed (OpenSSL):
  ```bash
  openssl req -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365
  ```

## .gitignore

Aggiungi:
```
node_modules/
.env
.env.local
certificates/*.pem
certificates/*.key
certificates/*.crt
uploads/
*.log
.DS_Store
```

## README.md

Documentazione base:
- Descrizione progetto
- Requisiti (Node.js, MongoDB)
- Installazione:
  ```bash
  npm install
  cp .env.example .env
  # Configura .env
  npm start
  ```
- Struttura progetto
- Variabili ambiente
- Health check endpoint
- Note su TLS e certificati

## TESTING

Dopo implementazione, verifica:

1. **Server avvia correttamente**:
   ```bash
   npm start
   ```
   Dovrebbe loggare: "Server running on port XXXX"

2. **Health check funziona**:
   ```bash
   curl http://localhost:3000/health
   # o
   curl https://localhost:3443/health
   ```
   Risposta JSON con status "ok" e database "connected"

3. **MongoDB connesso**:
   Verifica nei log che MongoDB sia connesso

4. **CORS funziona**:
   Testa da browser console o Postman con header Origin

5. **Error handling**:
   ```bash
   curl http://localhost:3000/api/v1/nonexistent
   ```
   Dovrebbe rispondere con 404 JSON

6. **TLS (se abilitato)**:
   Verifica che server risponda su HTTPS

## NOTE IMPORTANTI

- Usa **ES6 modules** (`import/export`) invece di CommonJS
- Tutti i file devono essere in formato ES6 modules
- Gestisci errori in modo elegante (non crashare server)
- Log tutto ciò che è importante (connessioni, errori, avvio)
- Codice pulito, commentato dove necessario
- Segui best practices Node.js/Express

## OUTPUT ATTESO

Al termine dovresti avere:
- ✅ Server Express funzionante
- ✅ Connessione MongoDB attiva
- ✅ Health check endpoint rispondente
- ✅ TLS configurato (se certificati presenti)
- ✅ Error handling funzionante
- ✅ CORS configurato
- ✅ Struttura progetto organizzata
- ✅ Documentazione base

**Pronto per Sezione 2 (Autenticazione)**


