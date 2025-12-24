import Donation from '../models/Donation.js';
import { NotFoundError, ValidationError } from '../middleware/errorHandler.js';
import logger from '../utils/logger.js';

/**
 * PUT /api/v1/donations/:id
 * Aggiorna donazione
 */
export async function updateDonation(req, res, next) {
  try {
    const { id } = req.params;
    const updateData = req.body;

    logger.info(`Aggiornamento donazione ${id}:`, { updateData });

    // Campi che possono essere aggiornati
    const allowedFields = [
      'stato',
      'cellaId',
      'lockerId',
      'isComunePickup',
      'descrizione',
      'categoria',
      'fotoUrl',
    ];

    // Filtra solo i campi consentiti
    const filteredUpdate = {};
    for (const field of allowedFields) {
      if (updateData[field] !== undefined) {
        filteredUpdate[field] = updateData[field];
      }
    }

    logger.info(`Campi filtrati per aggiornamento:`, { filteredUpdate });

    // Verifica che ci sia almeno un campo da aggiornare
    if (Object.keys(filteredUpdate).length === 0) {
      throw new ValidationError('Nessun campo valido da aggiornare');
    }

    // Trova e aggiorna la donazione
    const donation = await Donation.findOneAndUpdate(
      { donazioneId: id },
      { $set: filteredUpdate },
      { new: true, runValidators: true }
    );

    if (!donation) {
      throw new NotFoundError(`Donazione con ID ${id} non trovata`);
    }

    logger.info(`Donazione ${id} aggiornata con successo: ${Object.keys(filteredUpdate).join(', ')}`);

    // Formatta donazione per frontend
    const donationFormattata = {
      id: donation.donazioneId,
      donorName: donation.utenteId, // Potrebbe essere necessario un lookup
      itemName: donation.descrizione || '',
      itemDescription: donation.descrizione || '',
      category: donation.categoria || '',
      status: donation.stato,
      photoUrl: donation.fotoUrl || null,
      lockerId: donation.lockerId || null,
      cellId: donation.cellaId || null,
      isComunePickup: donation.isComunePickup || false,
      createdAt: donation.dataCreazione,
    };

    res.json({
      success: true,
      data: {
        donation: donationFormattata,
      },
    });
  } catch (error) {
    logger.error(`Errore nell'aggiornamento della donazione ${id}: ${error.message}`, {
      stack: error.stack,
      donationId: id,
      updateData: req.body,
    });
    next(error);
  }
}

export default {
  updateDonation,
};

