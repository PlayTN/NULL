# PROMPT COMPLETO - SEZIONE 2: Autenticazione Backend NULL

## CONTESTO DEL PROGETTO

Stai sviluppando il sistema di autenticazione per **NULL** (UrbanLock). Il frontend Flutter si aspetta:
- Login con SPID/CIE (per ora mock)
- JWT tokens per autenticazione
- Refresh token per rinnovare access token
- Endpoint per ottenere info utente corrente

**Base URL API**: `https://api.null.app/api/v1`  
**Formato**: JSON  
**Autenticazione**: JWT Bearer Token

## OBIETTIVO SEZIONE 2

Implementare sistema di autenticazione completo con:
1. Modello User MongoDB (Mongoose)
2. Login mock SPID/CIE con generazione JWT
3. Refresh token per rinnovare access token
4. Middleware per proteggere route
5. Endpoint per info utente corrente
6. Validazione input con express-validator

## STACK TECNOLOGICO RICHIESTO

- **jsonwebtoken**: v9+ (generazione e verifica JWT)
- **bcryptjs**: v2+ (hash password - per futuro, non necessario ora)
- **express-validator**: v7+ (già installato - validazione input)
- **Mongoose**: v8+ (già installato - modello User)

## STRUTTURA FILE DA CREARE

```
backend/src/
├── models/
│   └── User.js                    # Modello utente MongoDB
├── routes/
│   └── auth.js                    # Route autenticazione
├── controllers/
│   └── authController.js          # Logica business autenticazione
├── services/
│   └── authService.js            # Servizio JWT (generazione/verifica)
└── middleware/
    └── auth.js                   # Middleware protezione route
```

## DETTAGLI IMPLEMENTAZIONE

### 1. Installare Dipendenze

Aggiungi a `package.json`:
```json
"dependencies": {
  "jsonwebtoken": "^9.0.2",
  "bcryptjs": "^2.4.3"
}
```

Poi esegui: `npm install`

### 2. Aggiornare .env.example

Aggiungi variabili JWT:
```env
# JWT Configuration
JWT_SECRET=your-super-secret-key-change-in-production
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
```

### 3. src/models/User.js

**Schema MongoDB per utente:**

Campi richiesti:
- `_id`: ObjectId (automatico)
- `utenteId`: String (es. "USR-001") - ID univoco utente
- `email`: String (opzionale, per futuro)
- `nome`: String (nome utente)
- `cognome`: String (cognome utente)
- `codiceFiscale`: String (per SPID/CIE mock)
- `tipoAutenticazione`: String enum ["spid", "cie"] - come si è autenticato
- `ruolo`: String enum ["utente", "operatore", "admin"] - default "utente"
- `attivo`: Boolean - default true
- `dataCreazione`: Date - default Date.now
- `ultimoAccesso`: Date - aggiornato ad ogni login
- `refreshToken`: String (opzionale) - per refresh token

**Metodi:**
- `toJSON()`: Rimuove campi sensibili (refreshToken) dalla serializzazione
- `updateLastAccess()`: Aggiorna ultimoAccesso

**Index:**
- `utenteId`: unique
- `codiceFiscale`: unique (se presente)

### 4. src/services/authService.js

**Servizio per gestione JWT:**

Funzioni da implementare:

**`generateTokens(user)`**
- Genera access token e refresh token
- Access token: payload con `userId`, `utenteId`, `ruolo`
- Refresh token: payload con `userId`, `type: 'refresh'`
- Usa `JWT_SECRET` da env
- Scadenza: `JWT_ACCESS_EXPIRES_IN` (default 15m) e `JWT_REFRESH_EXPIRES_IN` (default 7d)
- Ritorna: `{ accessToken, refreshToken }`

**`verifyToken(token, type = 'access')`**
- Verifica e decodifica JWT
- Se `type === 'refresh'`, verifica che payload.type === 'refresh'
- Ritorna payload decodificato o lancia errore

**`generateAccessToken(user)`**
- Genera solo access token (per refresh)

**Esempio struttura token:**
```javascript
// Access token payload
{
  userId: user._id,
  utenteId: user.utenteId,
  ruolo: user.ruolo,
  iat: timestamp,
  exp: timestamp
}

// Refresh token payload
{
  userId: user._id,
  type: 'refresh',
  iat: timestamp,
  exp: timestamp
}
```

### 5. src/controllers/authController.js

**Controller per logica autenticazione:**

**`login(req, res, next)`**
- Valida input (email/codiceFiscale, tipoAutenticazione)
- **MOCK**: Cerca utente per codiceFiscale o crea nuovo utente
- Se utente non esiste, crea nuovo utente con:
  - `utenteId`: generato sequenziale (es. "USR-001", "USR-002")
  - `nome`, `cognome`: da input mock
  - `codiceFiscale`: da input
  - `tipoAutenticazione`: "spid" o "cie"
- Genera tokens con `authService.generateTokens()`
- Salva refreshToken nell'utente (opzionale, per revoca)
- Aggiorna `ultimoAccesso`
- Ritorna:
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "utenteId": "USR-001",
        "nome": "Mario",
        "cognome": "Rossi",
        "ruolo": "utente"
      },
      "tokens": {
        "accessToken": "eyJhbGc...",
        "refreshToken": "eyJhbGc...",
        "expiresIn": 900
      }
    }
  }
  ```

**`refreshToken(req, res, next)`**
- Valida input (refreshToken)
- Verifica refresh token con `authService.verifyToken(token, 'refresh')`
- Trova utente per userId
- Verifica che utente esista e sia attivo
- Genera nuovo access token
- Ritorna nuovo access token

**`getMe(req, res, next)`**
- Estrae userId da `req.user` (set dal middleware auth)
- Trova utente completo
- Ritorna info utente (senza campi sensibili)

**`logout(req, res, next)`**
- Opzionale: invalida refresh token (rimuove da utente)
- Ritorna success

### 6. src/middleware/auth.js

**Middleware per proteggere route:**

**`authenticate(req, res, next)`**
- Estrae token da header `Authorization: Bearer <token>`
- Se token mancante: errore 401 "Token mancante"
- Verifica token con `authService.verifyToken()`
- Trova utente per userId dal token
- Verifica che utente esista e sia attivo
- Aggiunge `req.user` con dati utente
- Chiama `next()`

**Gestione errori:**
- Token mancante → 401
- Token invalido/scaduto → 401
- Utente non trovato → 401
- Utente non attivo → 403

**Esempio uso:**
```javascript
router.get('/protected', authenticate, (req, res) => {
  // req.user contiene dati utente
  res.json({ user: req.user });
});
```

### 7. src/routes/auth.js

**Route Express per autenticazione:**

**POST `/api/v1/auth/login`**
- Body: `{ codiceFiscale: string, tipoAutenticazione: "spid" | "cie", nome?: string, cognome?: string }`
- Validazione: express-validator
- Controller: `authController.login`

**POST `/api/v1/auth/refresh`**
- Body: `{ refreshToken: string }`
- Validazione: express-validator
- Controller: `authController.refreshToken`

**GET `/api/v1/auth/me`**
- Header: `Authorization: Bearer <accessToken>`
- Middleware: `authenticate`
- Controller: `authController.getMe`

**POST `/api/v1/auth/logout`** (opzionale)
- Header: `Authorization: Bearer <accessToken>`
- Middleware: `authenticate`
- Controller: `authController.logout`

### 8. Aggiornare src/server.js

Aggiungi route auth:
```javascript
import authRoutes from './routes/auth.js';
// ...
app.use(`/api/${config.apiVersion}/auth`, authRoutes);
```

## VALIDAZIONE INPUT

Usa express-validator per validare:

**Login:**
- `codiceFiscale`: required, string, min 16 caratteri
- `tipoAutenticazione`: required, enum ["spid", "cie"]
- `nome`: optional, string (per creazione nuovo utente)
- `cognome`: optional, string (per creazione nuovo utente)

**Refresh Token:**
- `refreshToken`: required, string, non vuoto

## GESTIONE ERRORI

Usa le classi error esistenti (`UnauthorizedError`, `ValidationError`):

- **401 Unauthorized**: Token mancante/invalido/scaduto
- **403 Forbidden**: Utente non attivo
- **400 Bad Request**: Validazione input fallita
- **404 Not Found**: Utente non trovato (raro)

## FLUSSO LOGIN MOCK

1. Client invia: `POST /api/v1/auth/login` con `codiceFiscale` e `tipoAutenticazione`
2. Server cerca utente per `codiceFiscale`
3. Se non esiste:
   - Crea nuovo utente
   - Genera `utenteId` sequenziale
4. Genera JWT tokens (access + refresh)
5. Aggiorna `ultimoAccesso`
6. Ritorna tokens e info utente

## FLUSSO REFRESH TOKEN

1. Client invia: `POST /api/v1/auth/refresh` con `refreshToken`
2. Server verifica refresh token
3. Trova utente
4. Genera nuovo access token
5. Ritorna nuovo access token

## FLUSSO GET ME

1. Client invia: `GET /api/v1/auth/me` con header `Authorization: Bearer <token>`
2. Middleware `authenticate` verifica token
3. Estrae userId e trova utente
4. Ritorna info utente

## TESTING

Dopo implementazione, testa:

1. **Login nuovo utente:**
   ```bash
   curl -X POST http://localhost:3000/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"codiceFiscale":"RSSMRA80A01H501U","tipoAutenticazione":"spid","nome":"Mario","cognome":"Rossi"}'
   ```

2. **Login utente esistente:**
   ```bash
   curl -X POST http://localhost:3000/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"codiceFiscale":"RSSMRA80A01H501U","tipoAutenticazione":"spid"}'
   ```

3. **Refresh token:**
   ```bash
   curl -X POST http://localhost:3000/api/v1/auth/refresh \
     -H "Content-Type: application/json" \
     -d '{"refreshToken":"<refresh_token_da_login>"}'
   ```

4. **Get me (protetto):**
   ```bash
   curl http://localhost:3000/api/v1/auth/me \
     -H "Authorization: Bearer <access_token_da_login>"
   ```

5. **Test senza token (dovrebbe fallire):**
   ```bash
   curl http://localhost:3000/api/v1/auth/me
   ```

## NOTE IMPORTANTI

- **JWT_SECRET**: Usa una chiave sicura in produzione (almeno 32 caratteri random)
- **Scadenza token**: Access token breve (15 min), refresh token lungo (7 giorni)
- **Sicurezza**: Non loggare mai tokens completi
- **Mock**: Per ora login è mock, in futuro integrare SPID/CIE reali
- **UtenteId**: Genera sequenzialmente (es. "USR-001", "USR-002")
- **Refresh token**: Puoi salvare in DB per revoca (opzionale)

## OUTPUT ATTESO

Al termine dovresti avere:
- ✅ Modello User MongoDB funzionante
- ✅ Login mock con generazione JWT
- ✅ Refresh token endpoint
- ✅ Middleware auth per proteggere route
- ✅ Endpoint /me per info utente
- ✅ Validazione input completa
- ✅ Gestione errori appropriata

**Pronto per Sezione 3 (Gestione Locker)**

