/**
 * Script per pulire il database dalle donazioni con tipoAttrezzatura non valido
 * 
 * Valori validi: 'sport', 'libri', 'giochi', 'altro'
 * 
 * Questo script:
 * 1. Trova tutte le donazioni con tipoAttrezzatura non valido
 * 2. Le elimina dal database
 * 
 * Uso: node scripts/cleanup-donazioni-tipo-attrezzatura.js
 */

import mongoose from 'mongoose';
import Donazione from '../src/models/Donazione.js';
import config from '../src/config/env.js';
import logger from '../src/utils/logger.js';

// Valori validi per tipoAttrezzatura
const TIPI_VALIDI = ['sport', 'libri', 'giochi', 'altro'];

async function cleanupDonazioni() {
  try {
    // Connetti al database
    await mongoose.connect(config.mongodbUri, {
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    
    logger.info('Connesso al database MongoDB');

    // Trova tutte le donazioni con tipoAttrezzatura non valido
    const donazioniNonValide = await Donazione.find({
      tipoAttrezzatura: { $nin: TIPI_VALIDI }
    }).lean();

    logger.info(`Trovate ${donazioniNonValide.length} donazioni con tipoAttrezzatura non valido`);

    if (donazioniNonValide.length === 0) {
      logger.info('Nessuna donazione da eliminare. Database già pulito.');
      await mongoose.disconnect();
      process.exit(0);
    }

    // Mostra le donazioni che verranno eliminate
    console.log('\n=== Donazioni da eliminare ===');
    donazioniNonValide.forEach((donazione) => {
      console.log(`- ${donazione.donazioneId}: tipoAttrezzatura="${donazione.tipoAttrezzatura}"`);
    });
    console.log('');

    // Elimina le donazioni non valide
    const result = await Donazione.deleteMany({
      tipoAttrezzatura: { $nin: TIPI_VALIDI }
    });

    logger.info(`Eliminate ${result.deletedCount} donazioni con tipoAttrezzatura non valido`);

    // Verifica che non ci siano più donazioni non valide
    const donazioniRimanenti = await Donazione.find({
      tipoAttrezzatura: { $nin: TIPI_VALIDI }
    }).countDocuments();

    if (donazioniRimanenti > 0) {
      logger.warn(`ATTENZIONE: Rimangono ${donazioniRimanenti} donazioni non valide`);
    } else {
      logger.info('✓ Database pulito con successo. Tutte le donazioni hanno tipoAttrezzatura valido.');
    }

    // Mostra statistiche finali
    const totalDonazioni = await Donazione.countDocuments();
    const donazioniPerTipo = await Donazione.aggregate([
      {
        $group: {
          _id: '$tipoAttrezzatura',
          count: { $sum: 1 }
        }
      },
      { $sort: { count: -1 } }
    ]);

    console.log('\n=== Statistiche finali ===');
    console.log(`Totale donazioni: ${totalDonazioni}`);
    console.log('\nDonazioni per tipo:');
    donazioniPerTipo.forEach((item) => {
      console.log(`  - ${item._id || '(null)'}: ${item.count}`);
    });

    await mongoose.disconnect();
    logger.info('Disconnesso dal database');
    process.exit(0);
  } catch (error) {
    logger.error('Errore durante la pulizia del database:', error);
    await mongoose.disconnect();
    process.exit(1);
  }
}

// Esegui lo script
cleanupDonazioni();

