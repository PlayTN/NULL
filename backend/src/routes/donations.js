import express from 'express';
import { updateDonation } from '../controllers/donationController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

/**
 * PUT /api/v1/donations/:id
 * Aggiorna donazione
 * Parametro: :id (donazioneId)
 * Body: { stato?, cellaId?, lockerId?, isComunePickup?, descrizione?, categoria?, fotoUrl? }
 * Richiede autenticazione
 */
router.put('/:id', authenticate, updateDonation);

export default router;

