import mongoose from 'mongoose';
import logger from '../utils/logger.js';

const affittoSchema = new mongoose.Schema(
  {
    affittoId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    cellaId: {
      type: String,
      required: true,
      index: true,
    },
    lockerId: {
      type: String,
      required: true,
      index: true,
    },
    nomeAzienda: {
      type: String,
      required: true,
      trim: true,
    },
    codiceFiscale: {
      type: String,
      required: false,
      trim: true,
      default: null,
    },
    partitaIva: {
      type: String,
      required: false,
      trim: true,
      default: null,
    },
    dataStipulazione: {
      type: Date,
      required: true,
      default: Date.now,
      index: true,
    },
    dataScadenza: {
      type: Date,
      required: false,
      default: null,
    },
    attivo: {
      type: Boolean,
      default: true,
      index: true,
    },
    operatoreCreatoreId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Operatore',
      required: false,
      default: null,
    },
    note: {
      type: String,
      default: null,
      trim: true,
    },
    dataCreazione: {
      type: Date,
      default: Date.now,
    },
    dataAggiornamento: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: false,
    collection: 'affitto',
  }
);

// Index per performance
affittoSchema.index({ cellaId: 1, attivo: 1 });
affittoSchema.index({ lockerId: 1, attivo: 1 });
affittoSchema.index({ dataStipulazione: -1 });

// Metodo per rimuovere campi interni dalla serializzazione
affittoSchema.methods.toJSON = function () {
  const affittoObject = this.toObject();
  delete affittoObject.__v;
  return affittoObject;
};

/**
 * Metodo statico: genera affittoId univoco
 * Formato: "AFF-001", "AFF-002", ecc.
 */
affittoSchema.statics.generateAffittoId = async function () {
  const lastAffitto = await this.findOne({}, { affittoId: 1 })
    .sort({ affittoId: -1 })
    .lean();

  if (!lastAffitto || !lastAffitto.affittoId) {
    return 'AFF-001';
  }

  const match = lastAffitto.affittoId.match(/AFF-(\d+)/);
  if (match) {
    const lastNumber = parseInt(match[1], 10);
    const nextNumber = lastNumber + 1;
    return `AFF-${nextNumber.toString().padStart(3, '0')}`;
  }

  return 'AFF-001';
};

const Affitto = mongoose.model('Affitto', affittoSchema);

export default Affitto;

