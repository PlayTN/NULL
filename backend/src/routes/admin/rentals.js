import express from 'express';
import {
  createAffitto,
  getAllAffitti,
  getAffittoById,
  getAffittoByCellId,
  getAffittiByLockerId,
  terminateAffitto,
} from '../../controllers/affittoController.js';
import { authenticate } from '../../middleware/auth.js';
import { requireAdmin } from '../../middleware/admin.js';

const router = express.Router();

/**
 * POST /api/v1/admin/rentals
 * Creare affitto cella commerciale
 * Richiede autenticazione e ruolo admin/operatore
 */
router.post('/', authenticate, requireAdmin, createAffitto);

/**
 * GET /api/v1/admin/rentals
 * Lista tutti gli affitti
 * Richiede autenticazione e ruolo admin/operatore
 */
router.get('/', authenticate, requireAdmin, getAllAffitti);

/**
 * GET /api/v1/admin/rentals/:id
 * Dettaglio affitto
 * Richiede autenticazione e ruolo admin/operatore
 */
router.get('/:id', authenticate, requireAdmin, getAffittoById);

/**
 * GET /api/v1/admin/rentals/cell/:cellId
 * Ottieni affitto attivo per una cella
 * Richiede autenticazione e ruolo admin/operatore
 */
router.get('/cell/:cellId', authenticate, requireAdmin, getAffittoByCellId);

/**
 * GET /api/v1/admin/rentals/locker/:lockerId
 * Ottieni tutti gli affitti attivi per un locker
 * Richiede autenticazione e ruolo admin/operatore
 */
router.get('/locker/:lockerId', authenticate, requireAdmin, getAffittiByLockerId);

/**
 * PUT /api/v1/admin/rentals/:id/terminate
 * Termina affitto
 * Richiede autenticazione e ruolo admin/operatore
 */
router.put('/:id/terminate', authenticate, requireAdmin, terminateAffitto);

export default router;

