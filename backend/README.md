# NULL Backend API

Backend API per il sistema smart locker NULL (Ecosistema Smart Locker Modulari e Connessi per la Smart City - Comune di Trento).

## Descrizione

API REST sviluppata con Node.js ed Express per gestire il sistema di smart locker modulari. Il backend fornisce endpoints per:

- Autenticazione utenti (SPID/CIE)
- Gestione locker e celle
- Depositi e noleggi
- Donazioni
- Segnalazioni
- Notifiche
- Sensori e allarmi

## Requisiti Non Funzionali (RNF)

Il sistema è progettato per rispettare i seguenti requisiti non funzionali:

- **RNF1 - Prestazioni**: Operazioni critiche <2 secondi nel 95% dei casi
- **RNF2 - Disponibilità**: Uptime minimo 99.5% mensile
- **RNF4 - Sicurezza**: TLS 1.3, autenticazione forte, validazione input
- **RNF5 - Privacy**: GDPR compliance, minimizzazione dati

## Requisiti

- **Node.js**: v18.0.0 o superiore
- **MongoDB**: v6.0 o superiore (locale o cloud)
- **npm**: v9.0 o superiore

## Installazione

1. **Clona il repository** (se non già fatto)

2. **Installa le dipendenze**:
   ```bash
   cd backend
   npm install
   ```

3. **Configura le variabili ambiente**:
   ```bash
   cp .env.example .env
   ```
   
   Modifica il file `.env` con le tue configurazioni:
   - `MONGODB_URI`: Stringa di connessione MongoDB (default: `mongodb://localhost:27017/Null` - **nota**: database "Null" con N maiuscola, case-sensitive)
   - `PORT`: Porta HTTP (default: 3000)
   - `HTTPS_PORT`: Porta HTTPS (default: 3443)
   - `TLS_ENABLED`: Abilita/disabilita TLS (default: false)
   - `JWT_SECRET`: Chiave segreta JWT (minimo 32 caratteri per RNF4)

4. **Avvia il server**:
   ```bash
   npm start
   ```
   
   Per sviluppo con auto-reload:
   ```bash
   npm run dev
   ```

## Struttura Progetto

```
backend/
├── src/
│   ├── config/          # Configurazioni (DB, TLS, env)
│   ├── middleware/      # Middleware Express
│   ├── routes/          # Route API
│   ├── controllers/     # Logica business (da implementare)
│   ├── services/        # Servizi (da implementare)
│   ├── models/          # Modelli MongoDB (da implementare)
│   ├── utils/           # Utility functions
│   └── server.js        # Entry point
├── certificates/        # Certificati TLS
├── uploads/            # File caricati
├── .env.example         # Template variabili ambiente
├── package.json
└── README.md
```

## Variabili Ambiente

Vedi `.env.example` per tutte le variabili disponibili.

### Variabili Principali

- `NODE_ENV`: Ambiente (development/production)
- `PORT`: Porta HTTP server
- `HTTPS_PORT`: Porta HTTPS server
- `MONGODB_URI`: Stringa connessione MongoDB
- `TLS_ENABLED`: Abilita TLS/HTTPS
- `CORS_ORIGIN`: Origini CORS consentite (separate da virgola)

## Health Check

Verifica lo stato del server:

```bash
curl http://localhost:3000/health
```

Risposta:
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

## TLS/HTTPS

Per abilitare HTTPS in sviluppo:

1. **Genera certificati self-signed**:
   ```bash
   cd certificates
   openssl req -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365
   ```

2. **Configura `.env`**:
   ```env
   TLS_ENABLED=true
   TLS_KEY_PATH=./certificates/key.pem
   TLS_CERT_PATH=./certificates/cert.pem
   ```

3. **Riavvia il server**

Per produzione, usa certificati reali (Let's Encrypt, etc.).

## API Endpoints

### Health Check
- `GET /health` - Health check
- `GET /api/v1/health` - Health check (con versione)

Altri endpoint saranno implementati nelle sezioni successive.

## Sviluppo

Il progetto è strutturato in sezioni incrementali:

1. ✅ **Sezione 1**: Setup base (completata)
2. ⏳ **Sezione 2**: Autenticazione
3. ⏳ **Sezione 3**: Gestione Locker
4. ⏳ **Sezione 4**: Gestione Celle
5. ⏳ **Sezione 5**: Depositi e Noleggi
6. ⏳ **Sezione 6**: Donazioni
7. ⏳ **Sezione 7**: Segnalazioni
8. ⏳ **Sezione 8**: Notifiche
9. ⏳ **Sezione 9**: Sensori e Allarmi
10. ⏳ **Sezione 10**: Audit e Operatori

## Testing

```bash
# Health check
curl http://localhost:3000/health

# Test 404
curl http://localhost:3000/api/v1/nonexistent
```

## Logging

I log sono gestiti con Winston:
- **Console**: Tutti i livelli in sviluppo
- **File**: Errori e log combinati in produzione (cartella `logs/`)

Livelli: `error`, `warn`, `info`, `debug`

## Troubleshooting

### MongoDB non si connette
- Verifica che MongoDB sia in esecuzione
- Controlla `MONGODB_URI` nel file `.env`
- Verifica i log per errori di connessione

### Porta già in uso
- Cambia `PORT` o `HTTPS_PORT` nel file `.env`
- Verifica che nessun altro processo usi la porta

### Certificati TLS non trovati
- Se `TLS_ENABLED=true`, assicurati che i certificati esistano
- Genera certificati self-signed per sviluppo (vedi sezione TLS)

## Licenza

ISC

## Supporto

Per problemi o domande, consulta la documentazione del progetto.

