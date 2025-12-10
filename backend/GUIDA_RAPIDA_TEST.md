# 🚀 Guida Rapida - Test Server

## ⚡ Test Veloce (3 Passi)

### 1️⃣ Installa Dipendenze
```bash
cd backend
npm install
```

### 2️⃣ Configura
```bash
# Copia .env.example in .env
cp .env.example .env

# Modifica .env se necessario (almeno MONGODB_URI)
```

### 3️⃣ Avvia e Testa
```bash
# Avvia server
npm start

# In un altro terminale, testa:
curl http://localhost:3000/health
```

## ✅ Risposta Attesa

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

## 🔍 Verifica MongoDB

Se `"database": "disconnected"`:
- Verifica che MongoDB sia in esecuzione
- Controlla `MONGODB_URI` in `.env`

## 🐛 Problemi?

- **npm non trovato** → Installa Node.js
- **Porta occupata** → Cambia `PORT` in `.env`
- **MongoDB errore** → Avvia MongoDB o usa MongoDB Atlas

