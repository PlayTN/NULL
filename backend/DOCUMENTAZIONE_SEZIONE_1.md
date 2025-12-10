# 📚 Documentazione Sezione 1 - Setup Base Backend NULL

## 🎯 Cosa Abbiamo Fatto

Questa documentazione spiega in modo semplice e passo-passo tutto quello che è stato implementato nella **Sezione 1: Setup Base** del backend NULL.

---

## 📋 Indice

1. [Panoramica Generale](#panoramica-generale)
2. [Struttura del Progetto](#struttura-del-progetto)
3. [File Creati e Spiegazione](#file-creati-e-spiegazione)
4. [Come Funziona](#come-funziona)
5. [Come Testare](#come-testare)
6. [Prossimi Passi](#prossimi-passi)

---

## 🎯 Panoramica Generale

**Cosa abbiamo fatto?**
Abbiamo creato le **fondamenta** del backend, cioè tutto quello che serve per far partire un server Node.js che:
- ✅ Si connette a MongoDB (database)
- ✅ Supporta HTTPS sicuro (TLS)
- ✅ Gestisce errori in modo intelligente
- ✅ Ha un endpoint per verificare che tutto funzioni (health check)
- ✅ È pronto per aggiungere nuove funzionalità

**In parole semplici:** Abbiamo costruito la "casa" del backend, ora possiamo aggiungere le "stanze" (autenticazione, locker, celle, ecc.).

---

## 📁 Struttura del Progetto

Ecco come è organizzato il progetto:

```
backend/
├── src/                          # Cartella principale del codice
│   ├── config/                   # Configurazioni (database, TLS, variabili)
│   │   ├── database.js          # Connessione a MongoDB
│   │   ├── env.js               # Gestione variabili ambiente
│   │   └── tls.js               # Configurazione HTTPS/TLS
│   ├── middleware/              # "Filtri" che processano le richieste
│   │   ├── errorHandler.js      # Gestisce gli errori
│   │   └── notFound.js          # Gestisce route non trovate (404)
│   ├── routes/                  # Endpoint API
│   │   └── health.js            # Endpoint per verificare che tutto funzioni
│   ├── utils/                   # Funzioni di utilità
│   │   └── logger.js            # Sistema di logging (registra eventi)
│   └── server.js                # File principale - avvia il server
├── certificates/                 # Cartella per certificati SSL (sicurezza)
├── uploads/                      # Cartella per file caricati (immagini, ecc.)
├── .env.example                  # Template per configurazioni
├── .gitignore                    # File da non salvare su Git
├── package.json                  # Lista dipendenze e comandi
└── README.md                     # Documentazione generale
```

---

## 📄 File Creati e Spiegazione

### 1. **package.json** 📦
**Cosa fa:** Definisce il progetto Node.js e le sue dipendenze.

**Contiene:**
- Nome progetto: `null-backend`
- Versione: `1.0.0`
- Dipendenze necessarie (Express, MongoDB, ecc.)
- Comandi per avviare il server (`npm start`, `npm run dev`)

**Perché serve:** Senza questo file, Node.js non sa quali librerie installare.

---

### 2. **.env.example** ⚙️
**Cosa fa:** Template con tutte le configurazioni necessarie.

**Contiene variabili come:**
- `PORT=3000` → Porta su cui gira il server
- `MONGODB_URI=...` → Indirizzo del database
- `TLS_ENABLED=false` → Se usare HTTPS o no
- `CORS_ORIGIN=...` → Da dove possono arrivare le richieste

**Perché serve:** Permette di configurare il server senza modificare il codice.

**Come usarlo:**
1. Copia `.env.example` e rinominalo in `.env`
2. Modifica i valori secondo le tue esigenze

---

### 3. **src/config/env.js** 🔧
**Cosa fa:** Legge e valida le variabili dal file `.env`.

**Funzionalità:**
- Carica le variabili ambiente
- Controlla che quelle obbligatorie ci siano
- Fornisce valori di default se mancano
- Esporta un oggetto `config` con tutte le configurazioni

**Esempio:**
```javascript
// Altri file possono importare così:
import config from './config/env.js';
console.log(config.port); // 3000
```

**Perché serve:** Centralizza tutte le configurazioni in un unico posto.

---

### 4. **src/config/database.js** 🗄️
**Cosa fa:** Gestisce la connessione a MongoDB.

**Funzionalità:**
- `connectDB()` → Si connette al database
- `disconnectDB()` → Si disconnette
- `isConnected()` → Verifica se è connesso
- Ascolta eventi (connesso, errore, disconnesso)

**Cosa succede:**
1. Quando il server parte, chiama `connectDB()`
2. Se MongoDB è disponibile, si connette
3. Se c'è un errore, lo registra nei log

**Perché serve:** Senza database, non possiamo salvare dati.

---

### 5. **src/config/tls.js** 🔒
**Cosa fa:** Configura HTTPS (connessione sicura).

**Funzionalità:**
- Legge i certificati SSL (file `.pem`)
- Se i certificati non ci sono, il server gira su HTTP normale
- Gestisce errori se i certificati sono corrotti

**Perché serve:** HTTPS cripta i dati tra client e server (più sicuro).

**Nota:** In sviluppo puoi usare HTTP, in produzione serve HTTPS.

---

### 6. **src/utils/logger.js** 📝
**Cosa fa:** Sistema di logging (registra eventi, errori, informazioni).

**Funzionalità:**
- Livelli: `error`, `warn`, `info`, `debug`
- In sviluppo: stampa a schermo con colori
- In produzione: salva anche su file

**Esempio uso:**
```javascript
logger.info('Server avviato');
logger.error('Errore connessione database');
```

**Perché serve:** Aiuta a capire cosa succede e debuggare problemi.

---

### 7. **src/middleware/errorHandler.js** ⚠️
**Cosa fa:** Cattura e gestisce tutti gli errori.

**Funzionalità:**
- Intercetta errori non gestiti
- Crea risposta JSON standard
- Logga l'errore completo
- Invia risposta appropriata al client

**Risposta standard:**
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

**Perché serve:** Evita che il server crashi e fornisce errori chiari.

---

### 8. **src/middleware/notFound.js** 🔍
**Cosa fa:** Gestisce richieste a route che non esistono (404).

**Esempio:**
- Richiesta: `GET /api/v1/route-che-non-esiste`
- Risposta: JSON con errore 404

**Perché serve:** Fornisce risposta chiara invece di errore generico.

---

### 9. **src/routes/health.js** ❤️
**Cosa fa:** Endpoint per verificare che il server funzioni.

**Endpoint disponibili:**
- `GET /health`
- `GET /api/v1/health`

**Risposta:**
```json
{
  "success": true,
  "status": "ok",
  "timestamp": "2025-01-XX...",
  "uptime": 12345,
  "database": "connected",
  "version": "1.0.0",
  "environment": "development"
}
```

**Perché serve:** Permette di verificare rapidamente che tutto funzioni.

---

### 10. **src/server.js** 🚀
**Cosa fa:** File principale che avvia tutto il server.

**Cosa fa passo-passo:**

1. **Importa tutto il necessario** (Express, configurazioni, middleware, route)

2. **Crea app Express** (il "motore" del server)

3. **Configura middleware:**
   - `helmet()` → Aggiunge sicurezza HTTP
   - `cors()` → Permette richieste dal frontend
   - `express.json()` → Legge JSON dalle richieste
   - Logger → Registra ogni richiesta

4. **Monta le route:**
   - `/health` → Health check
   - `/api/v1/health` → Health check (con versione)

5. **Aggiunge gestione errori:**
   - `notFound` → Route non trovate
   - `errorHandler` → Gestione errori

6. **Crea server HTTP o HTTPS:**
   - Se TLS abilitato → HTTPS
   - Altrimenti → HTTP

7. **Connette MongoDB** (chiama `connectDB()`)

8. **Avvia il server** sulla porta configurata

9. **Gestisce shutdown graceful:**
   - Quando il server si chiude, disconnette MongoDB correttamente

**Perché serve:** È il "cuore" che fa partire tutto.

---

## 🔄 Come Funziona

### Flusso di una Richiesta

1. **Client fa richiesta** → `GET http://localhost:3000/health`

2. **Server riceve richiesta** → Express intercetta

3. **Middleware processano:**
   - Helmet aggiunge sicurezza
   - CORS verifica origine
   - Logger registra la richiesta

4. **Route gestisce:**
   - Trova `/health` in `health.js`
   - Esegue la funzione
   - Verifica connessione MongoDB
   - Calcola uptime

5. **Risposta inviata:**
   - JSON con status e informazioni

6. **Se c'è errore:**
   - `errorHandler` lo cattura
   - Crea risposta JSON di errore
   - Logga l'errore

### Avvio del Server

```
1. Carica configurazioni (.env)
2. Crea app Express
3. Configura middleware
4. Monta route
5. Connette MongoDB
6. Avvia server HTTP/HTTPS
7. ✅ Server pronto!
```

---

## 🧪 Come Testare

### Prerequisiti

1. **Node.js installato** (v18+)
2. **MongoDB installato e in esecuzione** (o MongoDB Atlas)
3. **Dipendenze installate**

### Passo 1: Installa Dipendenze

```bash
cd backend
npm install
```

Questo installerà tutte le librerie necessarie (Express, MongoDB, ecc.).

### Passo 2: Configura Ambiente

```bash
# Copia il template
cp .env.example .env

# Modifica .env con le tue configurazioni
# Almeno modifica MONGODB_URI se MongoDB non è su localhost:27017
```

### Passo 3: Avvia il Server

```bash
npm start
```

Dovresti vedere:
```
=================================
NULL Backend v1.0.0
=================================
Server running on http://localhost:3000
Environment: development
API Version: v1
Health check: http://localhost:3000/health
=================================
```

### Passo 4: Testa Health Check

**Opzione 1: Browser**
Apri: `http://localhost:3000/health`

**Opzione 2: curl (Terminale)**
```bash
curl http://localhost:3000/health
```

**Opzione 3: Postman**
- Metodo: `GET`
- URL: `http://localhost:3000/health`

**Risposta attesa:**
```json
{
  "success": true,
  "status": "ok",
  "timestamp": "2025-01-XX...",
  "uptime": 123,
  "database": "connected",
  "version": "1.0.0",
  "environment": "development"
}
```

### Passo 5: Testa 404

```bash
curl http://localhost:3000/api/v1/nonexistent
```

**Risposta attesa:**
```json
{
  "success": false,
  "error": {
    "message": "Route not found: GET /api/v1/nonexistent",
    "code": "NOT_FOUND",
    "statusCode": 404
  }
}
```

### Problemi Comuni

**❌ Errore: "Cannot find module"**
→ Esegui `npm install`

**❌ Errore: "MongoDB connection error"**
→ Verifica che MongoDB sia in esecuzione
→ Controlla `MONGODB_URI` in `.env`

**❌ Errore: "Port already in use"**
→ Cambia `PORT` in `.env`
→ Oppure chiudi il processo che usa la porta

---

## ✅ Cosa Abbiamo Ottenuto

Dopo questa sezione, abbiamo:

✅ **Server Express funzionante**
- Risponde a richieste HTTP
- Supporta HTTPS (se configurato)

✅ **Connessione MongoDB**
- Si connette automaticamente
- Gestisce errori di connessione

✅ **Sistema di Logging**
- Registra eventi e errori
- Utile per debugging

✅ **Gestione Errori**
- Errori gestiti in modo elegante
- Risposte JSON standard

✅ **Health Check**
- Verifica rapida che tutto funzioni
- Mostra stato database

✅ **Sicurezza Base**
- Helmet per sicurezza HTTP
- CORS configurato
- Supporto TLS

✅ **Struttura Organizzata**
- Codice pulito e modulare
- Facile da estendere

---

## 🚀 Prossimi Passi

Ora che la base è pronta, possiamo aggiungere:

1. **Sezione 2: Autenticazione**
   - Login utenti
   - JWT tokens
   - Protezione route

2. **Sezione 3: Gestione Locker**
   - CRUD locker
   - Lista e dettagli

3. **Sezione 4: Gestione Celle**
   - Apertura/chiusura celle
   - Stato celle

4. E così via...

---

## 📝 Note Finali

- **Sviluppo:** Usa HTTP (più semplice)
- **Produzione:** Usa HTTPS (obbligatorio)
- **MongoDB:** Può essere locale o cloud (Atlas)
- **Logging:** Controlla i log per capire cosa succede
- **Errori:** Tutti gli errori sono loggati e gestiti

---

## 🎓 In Sintesi

Abbiamo costruito le **fondamenta** del backend:
- Server che funziona ✅
- Database connesso ✅
- Errori gestiti ✅
- Pronto per nuove funzionalità ✅

**Prossimo passo:** Aggiungere autenticazione (Sezione 2)!

---

*Documentazione creata per NULL Backend - Sezione 1*
*Data: Gennaio 2025*

