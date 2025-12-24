import express from 'express';
import { updateCellStatus } from '../../controllers/adminController.js';
import { authenticate } from '../../middleware/auth.js';
import { requireAdmin } from '../../middleware/admin.js';

const router = express.Router();

/**
 * PUT /api/v1/admin/cells/:id/status
 * Modificare stato cella (libera/manutenzione)
 * RF14: Modificare stato cella
 */
router.put('/:id/status', authenticate, requireAdmin, updateCellStatus);

export default router;

