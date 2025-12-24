import Affitto from '../models/Affitto.js';
import Cell from '../models/Cell.js';
import Locker from '../models/Locker.js';
import mongoose from 'mongoose';
import {
  NotFoundError,
  ValidationError,
  UnauthorizedError,
} from '../middleware/errorHandler.js';
import logger from '../utils/logger.js';

/**
 * Formatta Affitto come AffittoResponse per frontend
 */
function formatAffittoResponse(affitto) {
  return {
    id: affitto.affittoId,
    cellaId: affitto.cellaId,
    lockerId: affitto.lockerId,
    nomeAzienda: affitto.nomeAzienda,
    codiceFiscale: affitto.codiceFiscale || null,
    partitaIva: affitto.partitaIva || null,
    dataStipulazione: affitto.dataStipulazione,
    dataScadenza: affitto.dataScadenza || null,
    attivo: affitto.attivo,
    note: affitto.note || null,
  };
}

/**
 * POST /api/v1/admin/rentals
 * Creare affitto cella commerciale
 */
export async function createAffitto(req, res, next) {
  try {
    const { cellaId, lockerId, nomeAzienda, codiceFiscale, partitaIva, dataScadenza, note } = req.body;
    const operatoreId = req.user.userId;

    // Converti operatoreId (stringa) in ObjectId
    const operatoreObjectId = new mongoose.Types.ObjectId(operatoreId);

    // Validazione campi obbligatori
    if (!cellaId) {
      throw new ValidationError('cellaId è obbligatorio');
    }
    if (!lockerId) {
      throw new ValidationError('lockerId è obbligatorio');
    }
    if (!nomeAzienda || nomeAzienda.trim().length === 0) {
      throw new ValidationError('nomeAzienda è obbligatorio');
    }
    if ((!codiceFiscale || codiceFiscale.trim().length === 0) && 
        (!partitaIva || partitaIva.trim().length === 0)) {
      throw new ValidationError('codiceFiscale o partitaIva è obbligatorio');
    }

    // Verifica che la cella esista
    const cella = await Cell.findOne({ cellaId }).lean();
    if (!cella) {
      throw new NotFoundError(`Cella ${cellaId} non trovata`);
    }

    // Verifica che il locker esista
    const locker = await Locker.findOne({ lockerId }).lean();
    if (!locker) {
      throw new NotFoundError(`Locker ${lockerId} non trovato`);
    }

    // Verifica che non ci sia già un affitto attivo per questa cella
    const affittoEsistente = await Affitto.findOne({
      cellaId,
      attivo: true,
    }).lean();

    if (affittoEsistente) {
      throw new ValidationError('Cella già affittata. Termina l\'affitto esistente prima di crearne uno nuovo.');
    }

    // Genera affittoId
    const affittoId = await Affitto.generateAffittoId();

    // Crea Affitto
    const affitto = new Affitto({
      affittoId,
      cellaId,
      lockerId,
      nomeAzienda: nomeAzienda.trim(),
      codiceFiscale: codiceFiscale ? codiceFiscale.trim() : null,
      partitaIva: partitaIva ? partitaIva.trim() : null,
      dataStipulazione: new Date(),
      dataScadenza: dataScadenza ? new Date(dataScadenza) : null,
      attivo: true,
      operatoreCreatoreId: operatoreObjectId,
      note: note ? note.trim() : null,
      dataCreazione: new Date(),
      dataAggiornamento: new Date(),
    });

    await affitto.save();

    // Aggiorna lo stato della cella a "occupata" se necessario
    await Cell.updateOne(
      { cellaId },
      { 
        stato: 'occupata',
        dataAggiornamento: new Date(),
      }
    );

    // Formatta risposta
    const affittoResponse = formatAffittoResponse(affitto);

    logger.info(`Affitto creato: ${affittoId} per cella ${cellaId} da operatore ${operatoreId}`);

    res.status(201).json({
      success: true,
      data: {
        affitto: affittoResponse,
      },
    });
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/admin/rentals
 * Lista tutti gli affitti
 */
export async function getAllAffitti(req, res, next) {
  try {
    const { page = 1, limit = 20, lockerId, attivo } = req.query;

    // Valida paginazione
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);

    if (pageNum < 1) {
      throw new ValidationError('page deve essere >= 1');
    }

    if (limitNum < 1 || limitNum > 100) {
      throw new ValidationError('limit deve essere tra 1 e 100');
    }

    // Costruisci query
    const query = {};

    if (lockerId) {
      query.lockerId = lockerId;
    }

    if (attivo !== undefined) {
      query.attivo = attivo === 'true';
    }

    // Calcola skip
    const skip = (pageNum - 1) * limitNum;

    // Trova affitti con paginazione
    const affitti = await Affitto.find(query)
      .sort({ dataStipulazione: -1 })
      .skip(skip)
      .limit(limitNum)
      .lean();

    // Formatta risposte
    const items = affitti.map((affitto) => formatAffittoResponse(affitto));

    // Calcola total per paginazione
    const total = await Affitto.countDocuments(query);
    const totalPages = Math.ceil(total / limitNum);

    logger.info(`Affitti recuperati: ${items.length} items (page ${pageNum}/${totalPages})`);

    res.json({
      success: true,
      data: {
        items,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages,
        },
      },
    });
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/admin/rentals/:id
 * Dettaglio affitto
 */
export async function getAffittoById(req, res, next) {
  try {
    const { id } = req.params;

    // Trova Affitto
    const affitto = await Affitto.findOne({ affittoId: id }).lean();

    if (!affitto) {
      throw new NotFoundError('Affitto non trovato');
    }

    // Formatta risposta
    const affittoResponse = formatAffittoResponse(affitto);

    logger.info(`Dettaglio affitto ${id} recuperato`);

    res.json({
      success: true,
      data: {
        affitto: affittoResponse,
      },
    });
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/admin/rentals/cell/:cellId
 * Ottieni affitto attivo per una cella
 */
export async function getAffittoByCellId(req, res, next) {
  try {
    const { cellId } = req.params;

    // Trova Affitto attivo per questa cella
    const affitto = await Affitto.findOne({
      cellaId: cellId,
      attivo: true,
    }).lean();

    if (!affitto) {
      return res.json({
        success: true,
        data: {
          affitto: null,
        },
      });
    }

    // Formatta risposta
    const affittoResponse = formatAffittoResponse(affitto);

    logger.info(`Affitto attivo per cella ${cellId} recuperato`);

    res.json({
      success: true,
      data: {
        affitto: affittoResponse,
      },
    });
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/admin/rentals/locker/:lockerId
 * Ottieni tutti gli affitti attivi per un locker
 */
export async function getAffittiByLockerId(req, res, next) {
  try {
    const { lockerId } = req.params;

    // Trova tutti gli affitti attivi per questo locker
    const affitti = await Affitto.find({
      lockerId,
      attivo: true,
    })
      .sort({ dataStipulazione: -1 })
      .lean();

    // Formatta risposte
    const items = affitti.map((affitto) => formatAffittoResponse(affitto));

    logger.info(`Affitti attivi per locker ${lockerId} recuperati: ${items.length}`);

    res.json({
      success: true,
      data: {
        items,
      },
    });
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /api/v1/admin/rentals/:id/terminate
 * Termina affitto
 */
export async function terminateAffitto(req, res, next) {
  try {
    const { id } = req.params;
    const operatoreId = req.user.userId;

    // Trova Affitto
    const affitto = await Affitto.findOne({ affittoId: id });

    if (!affitto) {
      throw new NotFoundError('Affitto non trovato');
    }

    if (!affitto.attivo) {
      throw new ValidationError('Affitto già terminato');
    }

    // Termina affitto
    affitto.attivo = false;
    affitto.dataScadenza = new Date();
    affitto.dataAggiornamento = new Date();
    await affitto.save();

    // Aggiorna lo stato della cella a "libera"
    await Cell.updateOne(
      { cellaId: affitto.cellaId },
      { 
        stato: 'libera',
        dataAggiornamento: new Date(),
      }
    );

    // Formatta risposta
    const affittoResponse = formatAffittoResponse(affitto);

    logger.info(`Affitto ${id} terminato da operatore ${operatoreId}`);

    res.json({
      success: true,
      data: {
        affitto: affittoResponse,
      },
    });
  } catch (error) {
    next(error);
  }
}

export default {
  createAffitto,
  getAllAffitti,
  getAffittoById,
  getAffittoByCellId,
  getAffittiByLockerId,
  terminateAffitto,
};

