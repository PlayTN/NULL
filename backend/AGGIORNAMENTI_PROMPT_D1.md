# 📋 Aggiornamenti Prompt - Integrazione Documento D1

## 🎯 Panoramica

Tutti i prompt delle Sezioni 1, 2 e 3 sono stati aggiornati con le informazioni complete del **Documento D1: NULL v2.7**, includendo:
- Requisiti Funzionali (RF)
- Requisiti Non Funzionali (RNF)
- Tipologie locker complete
- Struttura database reale
- Compliance normativa

---

## 📝 Sezione 1: Setup Base - Aggiornamenti

### File Aggiornati
- `PROMPT_SEZIONE_1_COMPATTO_V2.txt` - Versione aggiornata

### Modifiche Principali

1. **Contesto Progetto**
   - Aggiunto riferimento a "Ecosistema Smart Locker Modulari per Smart City"
   - Aggiunto riferimento a Comune di Trento
   - Aggiunto riferimento a requisiti RNF

2. **Database MongoDB**
   - **IMPORTANTE**: Database si chiama **"Null"** con N maiuscola (case-sensitive)
   - Specificato esplicitamente nel prompt
   - Nota su case-sensitivity MongoDB

3. **Requisiti RNF Integrati**
   - **RNF1**: Prestazioni - Monitoraggio continuo, alert automatici
   - **RNF2**: Disponibilità 99.5% mensile - Health check per monitoraggio
   - **RNF4**: Sicurezza TLS 1.3 - Configurazione TLS obbligatoria
   - **RNF5**: GDPR - Logging conforme, gestione dati sensibili

4. **Configurazione TLS**
   - RNF4 richiede TLS 1.3
   - Note su certificati produzione (Let's Encrypt)

5. **Logging**
   - RNF1 richiede monitoraggio prestazioni
   - Logging completo per debugging e compliance

---

## 🔐 Sezione 2: Autenticazione - Aggiornamenti

### File Aggiornati
- `PROMPT_SEZIONE_2_COMPATTO_V2.txt` - Versione aggiornata

### Modifiche Principali

1. **Contesto Progetto**
   - Aggiunto riferimento a documento D1
   - Aggiunto riferimento a RF1 (Sign Up/Login SPID/CIE)
   - Aggiunto riferimento a RNF4 (Sicurezza) e RNF5 (GDPR)

2. **Modello User**
   - Allineato alla struttura reale DB (collezione "utente")
   - Campi aggiunti: `telefono`, `dataRegistrazione` (invece di dataCreazione)
   - RF1: Supporto account "figli" per minori (campo `genitoreId` opzionale)
   - GDPR: Metodo `toJSON()` rimuove campi sensibili

3. **Autenticazione**
   - RF1: Mock SPID/CIE per ora, in futuro integrare AgID
   - RNF4: JWT_SECRET minimo 32 caratteri
   - RNF4: Rate limiting futuro per anti brute-force
   - RNF4: Non loggare mai tokens completi

4. **GDPR Compliance (RNF5)**
   - Minimizzazione dati
   - Pseudonimizzazione
   - Diritti utente (accesso, rettifica, cancellazione)
   - Metodo `toJSON()` filtra dati sensibili

5. **Validazione**
   - RNF4: Validazione input obbligatoria
   - Codice fiscale: 16 caratteri A-Z0-9

---

## 🏢 Sezione 3: Gestione Locker - Aggiornamenti

### File Aggiornati
- `PROMPT_SEZIONE_3.md` - Versione completa aggiornata
- `PROMPT_SEZIONE_3_COMPATTO_V2.txt` - Versione compatta aggiornata

### Modifiche Principali

1. **Contesto Progetto**
   - Aggiunto riferimento completo a documento D1
   - Aggiunto riferimento a RF2 (Mappa postazioni)
   - Aggiunto riferimento a Comune di Trento

2. **Tipologie Locker Complete**
   - **Sportivi** (Parchi) - Attrezzature sportive e ricreative
   - **Personali** (Città) - Storage effetti personali
   - **Pet-Friendly** (Aree cani) - Ciotole, giochi, sacchetti
   - **Commerciali** (Ritiro prodotti) - Negozi locali, click & collect
   - **Cicloturistici** (Piste ciclabili) - Attrezzi manutenzione bici

3. **Requisiti RF2 Integrati**
   - Disponibilità tempo reale
   - Stato online/offline
   - Postazioni in manutenzione con date ripristino
   - Filtri per tipologia locker
   - Filtri per categoria contenuti (futuro)
   - Filtro distanza (futuro - index geospaziale)

4. **Modello Locker**
   - Campo opzionale `tipo` per tipologia locker
   - Campo opzionale `dataRipristino` per manutenzione
   - Index 2dsphere per ricerche geospaziali future

5. **Modello Cell**
   - Allineato alla struttura reale DB (collezione "cella")
   - Supporto 3 tipi: deposit, borrow, pickup
   - Mapping completo DB → Frontend

6. **Controller**
   - Calcolo disponibilità tempo reale (RF2)
   - Filtri tipologia locker (RF2)
   - Filtri tipo cella
   - Gestione stato manutenzione (RF2)

7. **Tariffe**
   - Modalità guadagno: Storage lockers a tariffa oraria
   - Tariffe basate su grandezza cella
   - Supporto campo `costo` se presente nel DB

8. **Performance**
   - RNF1: Operazioni critiche <2 secondi 95% casi
   - Indexing per query rapide
   - Calcolo tempo reale (no cache)

---

## 📊 Riepilogo Aggiornamenti

### Informazioni Aggiunte da D1

1. **Requisiti Funzionali**
   - RF1: Sign Up/Login SPID/CIE
   - RF2: Mappa postazioni con filtri
   - RF3/RF4: Apertura/restituzione vano
   - RF13/RF14: Gestione postazioni operatore

2. **Requisiti Non Funzionali**
   - RNF1: Prestazioni <2 secondi
   - RNF2: Disponibilità 99.5%
   - RNF4: Sicurezza TLS 1.3, autenticazione forte
   - RNF5: GDPR compliance

3. **Tipologie Locker**
   - 5 tipologie complete (sportivi, personali, petFriendly, commerciali, cicloturistici)

4. **Struttura Database**
   - Database: "Null" (N maiuscola)
   - Collezioni: "utente", "locker", "cella" (minuscole)
   - Campi allineati alla struttura reale

5. **Modalità Guadagno**
   - Storage lockers a tariffa oraria
   - Negozi pagano affitto celle commerciali

---

## 📁 File Creati/Aggiornati

### Sezione 1
- ✅ `PROMPT_SEZIONE_1_COMPATTO_V2.txt` - Versione aggiornata con D1

### Sezione 2
- ✅ `PROMPT_SEZIONE_2_COMPATTO_V2.txt` - Versione aggiornata con D1

### Sezione 3
- ✅ `PROMPT_SEZIONE_3.md` - Versione completa aggiornata con D1
- ✅ `PROMPT_SEZIONE_3_COMPATTO_V2.txt` - Versione compatta aggiornata

---

## 🎯 Punti Chiave Aggiornati

### Database
- ✅ Nome database: **"Null"** (N maiuscola) - case-sensitive
- ✅ Collezioni: "utente", "locker", "cella" (minuscole)
- ✅ Struttura allineata agli screenshot MongoDB

### Tipologie Locker
- ✅ 5 tipologie complete (non solo 3)
- ✅ Mapping dimensione → tipo se campo tipo non presente
- ✅ Supporto stato manutenzione con date ripristino

### Requisiti RNF
- ✅ RNF1: Prestazioni e monitoraggio
- ✅ RNF2: Disponibilità e uptime
- ✅ RNF4: Sicurezza TLS 1.3, JWT sicuri
- ✅ RNF5: GDPR compliance

### Requisiti RF
- ✅ RF1: SPID/CIE (mock per ora)
- ✅ RF2: Mappa postazioni, filtri, disponibilità tempo reale
- ✅ RF3/RF4: Base per apertura/chiusura (Sezione 4)

---

## 📝 Note Implementazione

### Database Case-Sensitive
**IMPORTANTE**: MongoDB è case-sensitive per nomi database. Il database si chiama **"Null"** con N maiuscola, non "null".

### Tipologie Locker
Se il campo `tipo` non è presente nel DB, determinarlo da:
- `dimensione`: small/medium → personali, large → sportivi
- Oppure aggiungere campo `tipo` se necessario

### Performance
- RNF1 richiede <2 secondi per operazioni critiche
- Usa indexing appropriato
- Calcolo tempo reale (no cache) per accuratezza RF2

### GDPR
- Minimizzazione dati
- Non esporre dati sensibili
- Metodo `toJSON()` filtra automaticamente

---

## ✅ Checklist Aggiornamenti

- ✅ Sezione 1: Aggiornata con RNF e database "Null"
- ✅ Sezione 2: Aggiornata con RF1, RNF4, RNF5, GDPR
- ✅ Sezione 3: Aggiornata con RF2, 5 tipologie locker, struttura DB reale
- ✅ Tutti i prompt allineati al documento D1
- ✅ Struttura database reale integrata
- ✅ Requisiti funzionali e non funzionali referenziati

---

## 🚀 Prossimi Passi

I prompt sono ora completi e allineati al documento D1. Possono essere usati per:
1. Implementazione Sezione 3
2. Implementazione Sezioni future
3. Riferimento per compliance RNF
4. Allineamento con requisiti RF

---

*Aggiornamento completato: Gennaio 2025*  
*Basato su: Documento D1 NULL v2.7*

