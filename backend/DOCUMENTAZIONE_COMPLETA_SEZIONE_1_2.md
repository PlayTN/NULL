# 📚 Documentazione Completa - Sezione 1 e 2 Backend NULL

## 🎯 Panoramica Generale

Documentazione completa di tutto quello che è stato implementato nelle **Sezione 1 (Setup Base)** e **Sezione 2 (Autenticazione)** del backend NULL.

---

## 📋 Indice

1. [Sezione 1: Setup Base](#sezione-1-setup-base)
2. [Sezione 2: Autenticazione](#sezione-2-autenticazione)
3. [Struttura Database MongoDB](#struttura-database-mongodb)
4. [File Creati](#file-creati)
5. [Endpoint API](#endpoint-api)
6. [Testing](#testing)
7. [Prossimi Passi](#prossimi-passi)

---

## 🏗️ Sezione 1: Setup Base

### Obiettivo
Configurare l'infrastruttura base del backend Node.js con Express, MongoDB, TLS, gestione errori e health check.

### Cosa è Stato Fatto

#### 1. **Struttura Progetto**
```
backend/
├── src/
│   ├── config/          # Configurazioni
│   ├── middleware/      # Middleware Express
│   ├── routes/          # Route API
│   ├── utils/           # Utility functions
│   └── server.js        # Entry point
├── certificates/         # Certificati TLS
├── uploads/             # File caricati
├── .env.example         # Template configurazioni
├── package.json         # Dipendenze
└── README.md            # Documentazione
```

#### 2. **File Configurazione**

**package.json**
- Dipendenze: express, mongoose, dotenv, helmet, cors, express-validator, winston
- Scripts: start, dev, test
- Type: module (ES6)

**src/config/env.js**
- Carica variabili ambiente da `.env`
- Valida variabili obbligatorie
- Fornisce valori di default
- Configurazioni: server, MongoDB, TLS, API, CORS, logging, JWT

**src/config/database.js**
- Connessione MongoDB con Mongoose
- Gestione eventi (connected, error, disconnected)
- Funzioni: connectDB(), disconnectDB(), isConnected()
- Shutdown graceful

**src/config/tls.js**
- Caricamento certificati SSL/TLS
- Supporto HTTPS
- Gestione errori se certificati mancanti

#### 3. **Middleware**

**src/middleware/errorHandler.js**
- Gestione errori centralizzata
- Classi errori personalizzate: ValidationError, UnauthorizedError, NotFoundError
- Risposta JSON standard
- Logging errori completi

**src/middleware/notFound.js**
- Handler 404 per route non trovate
- Risposta JSON standardizzata

#### 4. **Route**

**src/routes/health.js**
- `GET /health`
- `GET /api/v1/health`
- Verifica stato server e MongoDB
- Informazioni: uptime, database status, version

#### 5. **Server**

**src/server.js**
- App Express configurata
- Middleware: helmet, CORS, JSON parser, logging
- Route montate
- Server HTTP/HTTPS
- Shutdown graceful (SIGTERM, SIGINT)
- Gestione errori non gestiti

#### 6. **Utilità**

**src/utils/logger.js**
- Logger Winston configurato
- Livelli: error, warn, info, debug
- Output console in sviluppo
- Output file in produzione

---

## 🔐 Sezione 2: Autenticazione

### Obiettivo
Implementare sistema di autenticazione completo con JWT, login mock SPID/CIE, refresh token e protezione route.

### Cosa è Stato Fatto

#### 1. **Modello User**

**src/models/User.js**
- Schema MongoDB allineato alla struttura reale del database
- Campi:
  - `utenteId`: String (unique, indexed) - es. "USR-001"
  - `nome`: String (required)
  - `cognome`: String (required)
  - `codiceFiscale`: String (unique, indexed, uppercase)
  - `email`: String (opzionale)
  - `telefono`: String (opzionale)
  - `dataRegistrazione`: Date (default: now)
  - `tipoAutenticazione`: Enum ["spid", "cie"] (default: "spid")
  - `ruolo`: Enum ["utente", "operatore", "admin"] (default: "utente")
  - `attivo`: Boolean (default: true)
  - `ultimoAccesso`: Date
  - `refreshToken`: String (hidden, select: false)

- Metodi:
  - `toJSON()`: Rimuove campi sensibili dalla serializzazione
  - `updateLastAccess()`: Aggiorna ultimo accesso
  - `generateUtenteId()`: Genera ID sequenziale (USR-001, USR-002, ...)

- Index:
  - `utenteId`: unique
  - `codiceFiscale`: unique

#### 2. **Servizio JWT**

**src/services/authService.js**
- `generateTokens(user)`: Genera access token + refresh token
- `generateAccessToken(user)`: Genera solo access token (per refresh)
- `verifyToken(token, type)`: Verifica e decodifica JWT

**Configurazione Token:**
- Access token: payload `{userId, utenteId, ruolo}`, scadenza 15 minuti
- Refresh token: payload `{userId, type: 'refresh'}`, scadenza 7 giorni
- Secret: JWT_SECRET da configurazione

#### 3. **Controller Autenticazione**

**src/controllers/authController.js**

**login(req, res, next)**
- Valida input (codiceFiscale, tipoAutenticazione)
- Cerca utente esistente per codiceFiscale
- Se non esiste, crea nuovo utente con utenteId sequenziale
- Genera JWT tokens (access + refresh)
- Salva refreshToken in DB
- Aggiorna ultimoAccesso
- Ritorna: user info + tokens

**refreshToken(req, res, next)**
- Valida refreshToken
- Verifica token
- Trova utente
- Verifica utente attivo
- Genera nuovo access token
- Ritorna nuovo access token

**getMe(req, res, next)**
- Estrae userId da req.user (middleware)
- Trova utente completo
- Ritorna info utente (senza campi sensibili)

**logout(req, res, next)**
- Invalida refreshToken (rimuove da DB)
- Ritorna success

#### 4. **Middleware Autenticazione**

**src/middleware/auth.js**

**authenticate(req, res, next)**
- Estrae token da header `Authorization: Bearer <token>`
- Verifica token JWT
- Trova utente per userId
- Verifica utente attivo
- Aggiunge `req.user` con dati utente
- Gestione errori: 401 per token mancante/invalido, 403 per utente non attivo

#### 5. **Route Autenticazione**

**src/routes/auth.js**

**POST /api/v1/auth/login**
- Body: `{codiceFiscale, tipoAutenticazione, nome?, cognome?}`
- Validazione: express-validator
- Controller: login

**POST /api/v1/auth/refresh**
- Body: `{refreshToken}`
- Validazione: express-validator
- Controller: refreshToken

**GET /api/v1/auth/me**
- Header: `Authorization: Bearer <accessToken>`
- Middleware: authenticate
- Controller: getMe

**POST /api/v1/auth/logout**
- Header: `Authorization: Bearer <accessToken>`
- Middleware: authenticate
- Controller: logout

#### 6. **Validazione Input**

Usa express-validator per:
- `codiceFiscale`: required, string, length 16, formato A-Z0-9
- `tipoAutenticazione`: required, enum ["spid", "cie"]
- `nome/cognome`: optional, string, 1-100 caratteri
- `refreshToken`: required, string, non vuoto

#### 7. **Aggiornamenti**

**package.json**
- Aggiunte dipendenze: jsonwebtoken ^9.0.3, bcryptjs ^3.0.3

**src/config/env.js**
- Aggiunte variabili JWT:
  - `jwtSecret`: JWT_SECRET
  - `jwtAccessExpiresIn`: JWT_ACCESS_EXPIRES_IN (default: "15m")
  - `jwtRefreshExpiresIn`: JWT_REFRESH_EXPIRES_IN (default: "7d")

**src/server.js**
- Montate route auth: `/api/v1/auth`

**.env.example**
- Aggiunte variabili JWT

---

## 🗄️ Struttura Database MongoDB

### Collezione: `utente`

```javascript
{
  _id: ObjectId,
  utenteId: "USR-001",           // ID sequenziale univoco
  nome: "Mario",
  cognome: "Rossi",
  codiceFiscale: "RSSMRA80A01H501Z",  // Unique, uppercase
  email: "mario.rossi@example.com",  // Opzionale
  telefono: "+390461000001",         // Opzionale
  dataRegistrazione: Date,           // Data registrazione
  tipoAutenticazione: "spid" | "cie",
  ruolo: "utente" | "operatore" | "admin",
  attivo: Boolean,
  ultimoAccesso: Date,
  refreshToken: String               // Hidden, per revoca
}
```

### Altre Collezioni (per riferimento futuro)

**operatore**
- operatoreId, nome, cognome, username, passwordHash

**locker**
- lockerId, nome, coordinate, stato, dimensione, operatoreCreatoreId, dataCreazione

**cella**
- cellaId, lockerId, categoria, richiede_foto, stato, costo, grandezza, tipo, peso, fotoUrl

**noleggio**
- noleggioId, utenteId, cellaId, lockerId, dataInizio, oraInizio, dataFine, oraFine, stato

**donazione**
- donazioneId, utenteId, cellaId, descrizione, categoria, stato, fotoUrl, dataCreazione

**segnalazione**
- segnalazioneId, utenteId, cellaId, lockerId, descrizione, fotoUrl, priorita, stato, dataCreazione, operatoreAssegnatoId

**sensore**
- sensorId, lockerId, cellaId, sensor_type, status

**lettura_sensore**
- lockerId, cellaId, sensoreId, sensor_type, timestamp, value, unita

**allarme**
- alertId, lockerId, cellaId, sensorId, timestamp, alert_type, gravita, descrizione, risolto

**audit_operatore**
- logId, operatoreId, entita, lockerId, cellaId, campo, valorePrecedente, valoreNuovo, timestamp

---

## 📁 File Creati

### Sezione 1 (15 file)
1. `package.json`
2. `.env.example`
3. `.gitignore`
4. `README.md`
5. `src/config/env.js`
6. `src/config/database.js`
7. `src/config/tls.js`
8. `src/middleware/errorHandler.js`
9. `src/middleware/notFound.js`
10. `src/routes/health.js`
11. `src/utils/logger.js`
12. `src/server.js`
13. `certificates/README.md`
14. `DOCUMENTAZIONE_SEZIONE_1.md`
15. `GUIDA_RAPIDA_TEST.md`

### Sezione 2 (6 file)
1. `src/models/User.js`
2. `src/services/authService.js`
3. `src/controllers/authController.js`
4. `src/middleware/auth.js`
5. `src/routes/auth.js`
6. `RISULTATO_SEZIONE_2.md`

**Totale: 21 file creati**

---

## 🔌 Endpoint API

### Health Check
- `GET /health` - Health check base
- `GET /api/v1/health` - Health check con versione

### Autenticazione
- `POST /api/v1/auth/login` - Login utente (mock SPID/CIE)
- `POST /api/v1/auth/refresh` - Refresh access token
- `GET /api/v1/auth/me` - Info utente corrente (protetto)
- `POST /api/v1/auth/logout` - Logout (protetto)

---

## 🧪 Testing

### Test Sezione 1
✅ Server avviato correttamente
✅ Health check funzionante
✅ MongoDB connesso
✅ CORS configurato
✅ Error handling funzionante

### Test Sezione 2
✅ Login nuovo utente
✅ Login utente esistente
✅ Generazione JWT tokens
✅ Refresh token
✅ Middleware autenticazione
✅ Endpoint /me protetto

### Esempi Test

**Login:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "codiceFiscale": "RSSMRA80A01H501U",
    "tipoAutenticazione": "spid",
    "nome": "Mario",
    "cognome": "Rossi"
  }'
```

**Get Me:**
```bash
curl http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer <accessToken>"
```

---

## 🔒 Sicurezza

### Implementata
- ✅ Helmet per sicurezza HTTP headers
- ✅ CORS configurato
- ✅ JWT tokens con scadenza
- ✅ Validazione input
- ✅ Middleware protezione route
- ✅ Refresh token salvato in DB per revoca
- ✅ Verifica utente attivo

### Note
- JWT_SECRET: Cambiare in produzione (32+ caratteri random)
- Access token: 15 minuti (breve per sicurezza)
- Refresh token: 7 giorni (lungo per UX)
- HTTPS: Configurare in produzione

---

## 📊 Statistiche

### Codice
- **File creati**: 21
- **Linee di codice**: ~1500+
- **Dipendenze**: 9
- **Endpoint**: 6

### Funzionalità
- ✅ Server Express funzionante
- ✅ Connessione MongoDB
- ✅ Sistema autenticazione JWT
- ✅ Login mock SPID/CIE
- ✅ Refresh token
- ✅ Protezione route
- ✅ Validazione input
- ✅ Gestione errori

---

## 🚀 Prossimi Passi

### Sezione 3: Gestione Locker
- CRUD locker
- Lista locker
- Dettaglio locker
- Celle di un locker
- Statistiche celle

### Sezione 4: Gestione Celle
- Apertura/chiusura celle
- Stato celle
- Storico utilizzi

### Sezione 5: Depositi e Noleggi
- Creazione depositi
- Gestione noleggi
- Pagamenti

### Sezione 6-10: Altre funzionalità
- Donazioni
- Segnalazioni
- Notifiche
- Sensori e allarmi
- Audit e operatori

---

## 📝 Note Importanti

### Database
- Nome database: **Null** (con N maiuscola)
- MongoDB case-sensitive per nomi database
- Collezione utente: `utente` (minuscola)

### Configurazione
- File `.env` necessario per configurazioni
- JWT_SECRET deve essere sicuro in produzione
- MongoDB deve essere in esecuzione

### Sviluppo
- Server HTTP in sviluppo (porta 3000)
- HTTPS in produzione (configurare certificati)
- Logging completo per debugging

---

## ✅ Checklist Completamento

### Sezione 1
- ✅ Struttura progetto
- ✅ Configurazioni base
- ✅ Connessione MongoDB
- ✅ Health check
- ✅ Error handling
- ✅ Logging
- ✅ Documentazione

### Sezione 2
- ✅ Modello User
- ✅ Servizio JWT
- ✅ Controller auth
- ✅ Middleware auth
- ✅ Route auth
- ✅ Validazione
- ✅ Testing

---

## 🎓 Conclusione

**Sezione 1 e 2 completate con successo!**

Il backend NULL è ora operativo con:
- ✅ Infrastruttura base solida
- ✅ Sistema autenticazione completo
- ✅ Pronto per nuove funzionalità

**Prossimo passo:** Sezione 3 - Gestione Locker

---

*Documentazione creata: Gennaio 2025*  
*Backend NULL v1.0.0*

