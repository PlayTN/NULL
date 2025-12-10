# PROMPT COMPLETO - SEZIONE 3: Gestione Locker Backend NULL

## CONTESTO DEL PROGETTO

Stai sviluppando la gestione locker per **NULL** (Ecosistema Smart Locker Modulari e Connessi per la Smart City - Comune di Trento).

**Requisiti Funzionali RF2**: Mappa postazioni con visualizzazione tutte le postazioni installate, filtri per tipologia locker, disponibilità tempo reale, stato online/offline, postazioni in manutenzione con date ripristino, filtri per categoria contenuti, distanza utente, orari disponibilità.

**Tipologie Locker** (dal documento D1):
1. **Sportivi** (Parchi) - Attrezzature sportive e ricreative (palloni, racchette, frisbee, bocce)
2. **Personali** (Città) - Storage effetti personali temporanei (bagagli, borse)
3. **Pet-Friendly** (Aree cani) - Ciotole pieghevoli, giochi per cani, sacchetti igienici
4. **Commerciali** (Ritiro prodotti) - Negozi locali, ritiro H24, click & collect
5. **Cicloturistici** (Piste ciclabili) - Attrezzi manutenzione bici, kit riparazione, camere d'aria

**Tipi Celle** (dal frontend):
- **deposit**: Deposito oggetti personali (a pagamento)
- **borrow**: Prestito oggetti dalla comunità (gratuito o a tempo)
- **pickup**: Ritiro prodotti da negozi (già acquistati)

Il frontend Flutter si aspetta:
- Lista di tutti i locker con posizione, tipo, disponibilità
- Dettaglio locker con informazioni complete
- Lista celle di un locker con dettagli (tipo, disponibilità, prezzi)
- Statistiche celle per tipo (borrow, deposit, pickup)
- Filtri per tipologia locker

**Base URL API**: `https://api.null.app/api/v1`  
**Formato**: JSON  
**Autenticazione**: Opzionale per GET (pubblica per RF2 mappa postazioni)

## OBIETTIVO SEZIONE 3

Implementare gestione completa locker con:
1. Modello Locker MongoDB (allineato alla struttura reale del DB)
2. Modello Cell MongoDB (per celle)
3. CRUD locker (per ora solo GET, CREATE/UPDATE/DELETE in futuro - RF13/RF14)
4. Endpoint per lista locker con filtri tipologia (RF2)
5. Endpoint per dettaglio locker
6. Endpoint per celle di un locker con filtri tipo
7. Endpoint per statistiche celle
8. Calcolo disponibilità celle in tempo reale (RF2)
9. Supporto 5 tipologie locker (sportivi, personali, petFriendly, commerciali, cicloturistici)
10. Gestione stato online/offline e manutenzione (RF2)

## STRUTTURA FILE DA CREARE

```
backend/src/
├── models/
│   ├── Locker.js           # Modello locker MongoDB
│   └── Cell.js              # Modello cella MongoDB
├── routes/
│   └── lockers.js           # Route locker
└── controllers/
    └── lockerController.js  # Logica business locker
```

## STRUTTURA DATABASE MONGODB

### Collezione: `locker`

Dalla struttura reale del database:
```javascript
{
  _id: ObjectId,
  lockerId: "LCK-001",              // ID sequenziale univoco
  nome: "Locker Piazza Dante",       // Nome locker
  coordinate: {                      // Oggetto coordinate
    lat: 46.0718,                    // Latitudine
    lng: 11.1220                     // Longitudine
  },
  stato: "attivo",                   // Enum: "attivo", "manutenzione", "disattivo"
  dimensione: "large",               // Enum: "small", "medium", "large"
  operatoreCreatoreId: "OP-001",     // ID operatore che ha creato
  dataCreazione: Date                // Data creazione
}
```

**Nota**: Il campo `tipo` (sportivi/personali/...) potrebbe non essere presente nel DB. Determinalo da `dimensione` o aggiungi campo se necessario.

### Collezione: `cella`

Dalla struttura reale del database:
```javascript
{
  _id: ObjectId,
  cellaId: "CEL-001-1",              // ID formato: CEL-{lockerId}-{numero}
  lockerId: "LCK-001",               // Riferimento al locker
  categoria: "attrezzi sportivi",   // Categoria oggetto (se presente)
  richiede_foto: true,               // Se richiede foto per apertura
  stato: "libera",                   // Enum: "libera", "occupata", "manutenzione"
  costo: 0,                          // Costo (per ora 0, futuro tariffa oraria)
  grandezza: "piccola",              // Enum: "piccola", "media", "grande", "extra_large"
  tipo: "ordini",                    // Tipo: "ordini" (pickup), "deposito" (deposit), "prestito" (borrow)
  peso: 0,                           // Peso massimo supportato in kg
  fotoUrl: "https://...",            // URL foto cella (opzionale)
  operatoreCreatoreId: "OP-001",     // ID operatore creatore
  dataCreazione: Date                // Data creazione
}
```

## DETTAGLI IMPLEMENTAZIONE

### 1. src/models/Locker.js

**Schema MongoDB per locker:**

Campi richiesti:
- `lockerId`: String (unique, indexed) - es. "LCK-001"
- `nome`: String (required) - Nome locker
- `coordinate`: Object (required) - `{lat: Number, lng: Number}`
- `stato`: String enum ["attivo", "manutenzione", "disattivo"] (default: "attivo")
- `dimensione`: String enum ["small", "medium", "large"] (default: "medium")
- `operatoreCreatoreId`: String (opzionale) - ID operatore
- `dataCreazione`: Date (default: Date.now)

**Campi opzionali per RF2:**
- `tipo`: String enum ["sportivi", "personali", "petFriendly", "commerciali", "cicloturistici"] (opzionale, può essere calcolato)
- `descrizione`: String (opzionale)
- `dataRipristino`: Date (opzionale, se in manutenzione)

**Metodi virtuali:**
- `isActive`: Boolean - getter che verifica se stato === "attivo"

**Metodi:**
- `toJSON()`: Formatta coordinate e aggiunge campi calcolati per frontend
- `getTotalCells()`: Metodo statico - conta celle totali per questo locker
- `getAvailableCells()`: Metodo statico - conta celle disponibili (stato: "libera")

**Index:**
- `lockerId`: unique
- `coordinate`: 2dsphere index (per ricerche geospaziali future - RF2 filtro distanza)

**Nota:** Il frontend si aspetta anche `totalCells`, `availableCells`, `type` (LockerType), `description`, `availabilityPercentage`. Questi verranno calcolati nel controller.

### 2. src/models/Cell.js

**Schema MongoDB per cella:**

Campi richiesti:
- `cellaId`: String (unique, indexed) - es. "CEL-001-1"
- `lockerId`: String (required, indexed) - Riferimento al locker
- `categoria`: String (opzionale) - Categoria oggetto (es. "attrezzi sportivi")
- `richiede_foto`: Boolean (default: false)
- `stato`: String enum ["libera", "occupata", "manutenzione"] (default: "libera")
- `costo`: Number (default: 0) - Costo base (tariffa calcolata da grandezza)
- `grandezza`: String enum ["piccola", "media", "grande", "extra_large"] (default: "media")
- `tipo`: String enum ["ordini", "deposito", "prestito"] (default: "deposito")
- `peso`: Number (default: 0) - Peso massimo supportato in kg
- `fotoUrl`: String (opzionale) - URL foto cella
- `operatoreCreatoreId`: String (opzionale)
- `dataCreazione`: Date (default: Date.now)

**Metodi:**
- `isAvailable()`: Boolean - getter che verifica se stato === "libera"
- `toJSON()`: Formatta per frontend (aggiunge campi calcolati se necessario)

**Index:**
- `cellaId`: unique
- `lockerId`: indexed (per query rapide)

**Nota:** Il frontend si aspetta anche `cellNumber`, `type` (CellType), `size` (CellSize), `pricePerHour`, `pricePerDay`, `itemName`, `itemDescription`, `itemImageUrl`, `storeName`, `availableUntil`, `borrowDuration`. Questi verranno mappati/calcolati nel controller.

### 3. src/controllers/lockerController.js

**Controller per logica locker:**

**getAllLockers(req, res, next)**
- Query opzionali: `?type=sportivi|personali|petFriendly|commerciali|cicloturistici` (filtro per tipologia - RF2)
- Trova tutti i locker con stato "attivo" o "manutenzione" (RF2: mostra anche in manutenzione)
- Per ogni locker:
  - Calcola `totalCells`: conta celle per lockerId (tempo reale - RF2)
  - Calcola `availableCells`: conta celle con stato "libera" (tempo reale - RF2)
  - Determina `type`: 
    - Se campo `tipo` presente nel DB, usalo
    - Altrimenti mapping da `dimensione`: small/medium→personali, large→sportivi
    - Default: "personali"
  - Aggiungi `description`: da campo descrizione o genera da nome
  - Aggiungi `isActive`: stato === "attivo"
  - Aggiungi `availabilityPercentage`: (availableCells/totalCells)*100
  - Aggiungi `stato`: stato originale (per RF2)
  - Aggiungi `dataRipristino`: se in manutenzione (per RF2)
- Ritorna array di locker formattati per frontend

**Risposta:**
```json
{
  "success": true,
  "data": {
    "lockers": [
      {
        "id": "LCK-001",
        "name": "Locker Piazza Dante",
        "position": {
          "lat": 46.0718,
          "lng": 11.1220
        },
        "type": "personali",
        "totalCells": 25,
        "availableCells": 18,
        "isActive": true,
        "description": "Deposito effetti personali",
        "availabilityPercentage": 72.0,
        "stato": "attivo"
      }
    ]
  }
}
```

**getLockerById(req, res, next)**
- Parametro: `:id` (lockerId)
- Trova locker per lockerId
- Se non trovato: 404
- Calcola totalCells e availableCells (tempo reale)
- Determina type (come sopra)
- Ritorna locker completo formattato

**Risposta:**
```json
{
  "success": true,
  "data": {
    "locker": {
      "id": "LCK-001",
      "name": "Locker Piazza Dante",
      "position": { "lat": 46.0718, "lng": 11.1220 },
      "type": "personali",
      "totalCells": 25,
      "availableCells": 18,
      "isActive": true,
      "description": "...",
      "availabilityPercentage": 72.0,
      "stato": "attivo",
      "dimensione": "large",
      "dataCreazione": "2025-01-05T10:00:00.000Z"
    }
  }
}
```

**getLockerCells(req, res, next)**
- Parametro: `:id` (lockerId)
- Query opzionali: `?type=deposit|borrow|pickup` (filtro per tipo cella)
- Trova tutte le celle per lockerId
- Applica filtro tipo se presente (mapping: deposit→deposito, borrow→prestito, pickup→ordini)
- Per ogni cella:
  - Mappa `cellaId` → `id`
  - Mappa `grandezza` → `size`:
    - "piccola" → "small"
    - "media" → "medium"
    - "grande" → "large"
    - "extra_large" → "extraLarge"
  - Mappa `tipo` → `type`:
    - "ordini" → "pickup"
    - "deposito" → "deposit"
    - "prestito" → "borrow"
  - Calcola `cellNumber`: da cellaId (es. "CEL-001-1" → "Cella 1")
  - Calcola `isAvailable`: stato === "libera"
  - Calcola `pricePerHour` e `pricePerDay`: da tariffa basata su grandezza:
    - piccola: 0.5€/ora, 5€/giorno
    - media: 1€/ora, 10€/giorno
    - grande: 2€/ora, 20€/giorno
    - extra_large: 3€/ora, 30€/giorno
    - Oppure usa campo `costo` se presente e diverso da 0
  - Aggiungi campi opzionali:
    - `itemName`: da categoria (se tipo borrow/pickup)
    - `itemDescription`: da categoria (se tipo borrow/pickup)
    - `itemImageUrl`: da fotoUrl (se presente)
    - `storeName`: null (per ora, futuro per tipo pickup)
    - `availableUntil`: null (per ora, futuro per tipo pickup)
    - `borrowDuration`: null (per ora, futuro per tipo borrow)
- Ritorna array di celle formattate

**Risposta:**
```json
{
  "success": true,
  "data": {
    "cells": [
      {
        "id": "CEL-001-1",
        "cellNumber": "Cella 1",
        "type": "deposit",
        "size": "small",
        "isAvailable": true,
        "pricePerHour": 0.5,
        "pricePerDay": 5.0,
        "grandezza": "piccola",
        "richiede_foto": false,
        "categoria": null,
        "peso": 0
      }
    ]
  }
}
```

**getLockerCellStats(req, res, next)**
- Parametro: `:id` (lockerId)
- Aggrega celle per tipo e stato
- Calcola:
  - `totalCells`: totale celle per lockerId
  - `availableBorrowCells`: celle tipo "prestito" con stato "libera"
  - `availableDepositCells`: celle tipo "deposito" con stato "libera"
  - `availablePickupCells`: celle tipo "ordini" con stato "libera"
  - `totalAvailable`: somma di tutte le celle disponibili
- Ritorna statistiche

**Risposta:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "totalCells": 25,
      "availableBorrowCells": 5,
      "availableDepositCells": 10,
      "availablePickupCells": 3,
      "totalAvailable": 18
    }
  }
}
```

### 4. src/routes/lockers.js

**Route Express per locker:**

**GET /api/v1/lockers**
- Query params: `?type=sportivi|personali|petFriendly|commerciali|cicloturistici` (opzionale - RF2)
- Controller: `getAllLockers`
- Autenticazione: Opzionale (pubblica per RF2)

**GET /api/v1/lockers/:id**
- Parametro: `:id` (lockerId)
- Controller: `getLockerById`
- Autenticazione: Opzionale

**GET /api/v1/lockers/:id/cells**
- Parametro: `:id` (lockerId)
- Query params: `?type=deposit|borrow|pickup` (opzionale)
- Controller: `getLockerCells`
- Autenticazione: Opzionale

**GET /api/v1/lockers/:id/cells/stats**
- Parametro: `:id` (lockerId)
- Controller: `getLockerCellStats`
- Autenticazione: Opzionale

### 5. Aggiornare src/server.js

Aggiungi route lockers:
```javascript
import lockerRoutes from './routes/lockers.js';
// ...
app.use(`/api/${config.apiVersion}/lockers`, lockerRoutes);
```

## MAPPING DATI

### Locker: DB → Frontend

| Database | Frontend | Note |
|----------|----------|------|
| lockerId | id | String (es. "LCK-001") |
| nome | name | String |
| coordinate.lat, coordinate.lng | position.lat, position.lng | Object LatLng |
| stato === "attivo" | isActive | Boolean |
| stato | stato | "attivo" \| "manutenzione" \| "disattivo" (RF2) |
| dimensione o tipo | type | Mapping: sportivi/personali/petFriendly/commerciali/cicloturistici |
| - | totalCells | Calcolato: count celle (tempo reale - RF2) |
| - | availableCells | Calcolato: count celle "libera" (tempo reale - RF2) |
| descrizione o nome | description | Opzionale |
| - | availabilityPercentage | Calcolato: (availableCells/totalCells)*100 |
| - | online/offline | RF2: Stato connessione (futuro) |
| dataRipristino | dataRipristino | RF2: Se in manutenzione, data prevista ripristino |

### Cell: DB → Frontend

| Database | Frontend | Note |
|----------|----------|------|
| cellaId | id | String (es. "CEL-001-1") |
| - | cellNumber | Calcolato da cellaId (es. "CEL-001-1" → "Cella 1") |
| tipo | type | Mapping: "ordini"→pickup, "deposito"→deposit, "prestito"→borrow |
| grandezza | size | Mapping: "piccola"→small, "media"→medium, "grande"→large, "extra_large"→extraLarge |
| stato === "libera" | isAvailable | Boolean |
| costo, grandezza | pricePerHour, pricePerDay | Calcolato da tariffa basata su grandezza |
| categoria | itemName, itemDescription | Se tipo borrow/pickup |
| fotoUrl | itemImageUrl | Se presente |
| - | storeName | Opzionale, per tipo pickup (futuro) |
| - | availableUntil | Opzionale, per tipo pickup (futuro) |
| - | borrowDuration | Opzionale, per tipo borrow (futuro) |

## LOGICA TARIFFE

Calcola prezzi basati su grandezza (modalità guadagno progetto):
- **piccola**: 0.5€/ora, 5€/giorno
- **media**: 1€/ora, 10€/giorno
- **grande**: 2€/ora, 20€/giorno
- **extra_large**: 3€/ora, 30€/giorno

**Nota**: Storage lockers (personali) sono a tariffa oraria. Se campo `costo` è presente e diverso da 0, usalo come base e calcola proporzionalmente.

## GESTIONE ERRORI

- **404 Not Found**: Locker non trovato
- **400 Bad Request**: Parametri query invalidi
- **500 Internal Server Error**: Errori database

Usa classi error esistenti: `NotFoundError`, `ValidationError`

## TESTING

Dopo implementazione, testa:

1. **Lista tutti i locker:**
   ```bash
   curl http://localhost:3000/api/v1/lockers
   ```

2. **Lista locker filtrati per tipo:**
   ```bash
   curl http://localhost:3000/api/v1/lockers?type=sportivi
   curl http://localhost:3000/api/v1/lockers?type=personali
   curl http://localhost:3000/api/v1/lockers?type=commerciali
   ```

3. **Dettaglio locker:**
   ```bash
   curl http://localhost:3000/api/v1/lockers/LCK-001
   ```

4. **Celle di un locker:**
   ```bash
   curl http://localhost:3000/api/v1/lockers/LCK-001/cells
   ```

5. **Celle filtrate per tipo:**
   ```bash
   curl http://localhost:3000/api/v1/lockers/LCK-001/cells?type=deposit
   curl http://localhost:3000/api/v1/lockers/LCK-001/cells?type=borrow
   curl http://localhost:3000/api/v1/lockers/LCK-001/cells?type=pickup
   ```

6. **Statistiche celle:**
   ```bash
   curl http://localhost:3000/api/v1/lockers/LCK-001/cells/stats
   ```

## NOTE IMPORTANTI

- **Database**: Usa database "Null" con N maiuscola (case-sensitive MongoDB)
- **Collezioni**: "locker" e "cella" (minuscole)
- **Coordinate**: MongoDB supporta GeoJSON, ma per semplicità usa oggetto `{lat, lng}`. Index 2dsphere per ricerche geospaziali future (RF2: filtro distanza)
- **Calcolo celle**: Conta in tempo reale, non cache (RF2: disponibilità tempo reale)
- **Mapping tipo**: 
  - Locker: 5 tipologie (sportivi, personali, petFriendly, commerciali, cicloturistici)
  - Cell: 3 tipi (deposit, borrow, pickup)
- **Performance**: RNF1 richiede <2 secondi 95% casi. Indexing su lockerId, coordinate, stato per query rapide
- **Filtri**: RF2 richiede filtri per tipologia locker, categoria contenuti, distanza, orari (filtri distanza/orari implementati in futuro)
- **Stato locker**: RF2 richiede gestione online/offline, manutenzione con date ripristino
- **Compatibilità**: Formatta risposte per matchare esattamente quello che si aspetta il frontend Flutter
- **Tariffe**: Storage lockers a tariffa oraria (modalità guadagno progetto)
- **Tipologie locker**: Supporta tutte e 5 le tipologie definite nel documento D1

## OUTPUT ATTESO

Al termine dovresti avere:
- ✅ Modello Locker MongoDB funzionante (collezione "locker")
- ✅ Modello Cell MongoDB funzionante (collezione "cella")
- ✅ Endpoint lista locker con filtri tipologia (RF2)
- ✅ Endpoint dettaglio locker
- ✅ Endpoint celle locker con filtri tipo
- ✅ Endpoint statistiche celle
- ✅ Mapping dati DB → Frontend completo
- ✅ Calcolo disponibilità in tempo reale (RF2)
- ✅ Supporto 5 tipologie locker
- ✅ Gestione stato manutenzione (RF2)

**Pronto per Sezione 4 (Gestione Celle - Apertura/Chiusura)**
