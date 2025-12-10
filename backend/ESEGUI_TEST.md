# 🧪 Come Eseguire il Test Automatico

## Prerequisiti

1. **Node.js installato** (v18+)
   - Scarica da: https://nodejs.org/
   - Verifica: `node --version`

2. **npm installato** (viene con Node.js)
   - Verifica: `npm --version`

## Esegui Test di Verifica

### Opzione 1: Script di Verifica (Raccomandato)

```bash
cd backend
node test-setup.js
```

Questo script verificherà:
- ✅ Tutti i file necessari presenti
- ✅ Struttura cartelle corretta
- ✅ package.json valido
- ✅ Dipendenze installate
- ✅ File .env configurato

### Opzione 2: Test Completo (Installazione + Avvio)

```bash
cd backend

# 1. Installa dipendenze
npm install

# 2. Configura ambiente
Copy-Item .env.example .env
# Modifica .env se necessario

# 3. Avvia server
npm start
```

In un altro terminale:
```bash
# 4. Testa health check
curl http://localhost:3000/health

# Oppure con PowerShell:
Invoke-WebRequest -Uri http://localhost:3000/health
```

## Risultato Atteso

### Script di Verifica
Dovresti vedere:
```
==================================================
  VERIFICA SETUP BACKEND NULL
==================================================

✓ File trovato: package.json
✓ File trovato: src/server.js
...
✓ Successi: XX
⚠ Avvisi: X (se node_modules non installato)
✗ Errori: 0
```

### Health Check
Risposta JSON:
```json
{
  "success": true,
  "status": "ok",
  "timestamp": "2025-01-XX...",
  "uptime": 123,
  "database": "connected" o "disconnected",
  "version": "1.0.0",
  "environment": "development"
}
```

## Se Node.js Non È Installato

1. **Installa Node.js:**
   - Vai su: https://nodejs.org/
   - Scarica LTS (Long Term Support)
   - Installa
   - Riavvia terminale/PowerShell

2. **Verifica installazione:**
   ```bash
   node --version
   npm --version
   ```

3. **Riesegui i test**

## Troubleshooting

### "node: command not found"
→ Node.js non installato o non nel PATH
→ Reinstalla Node.js e riavvia terminale

### "npm: command not found"
→ npm non disponibile
→ Reinstalla Node.js (npm viene incluso)

### "Cannot find module"
→ Esegui: `npm install`

### "Port 3000 already in use"
→ Cambia `PORT` in `.env` o chiudi processo sulla porta 3000

---

*Usa `node test-setup.js` per una verifica rapida!*

