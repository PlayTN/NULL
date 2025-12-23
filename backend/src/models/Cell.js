import mongoose from 'mongoose';

const cellSchema = new mongoose.Schema(
  {
    cellaId: {
      type: String,
      required: true,
      unique: true,
    },
    lockerId: {
      type: String,
      required: true,
    },
    categoria: {
      type: String,
      trim: true,
      default: null,
    },
    richiede_foto: {
      type: Boolean,
      default: false,
    },
    stato: {
      type: String,
      enum: ['libera', 'occupata', 'manutenzione'],
      default: 'libera',
    },
    costo: {
      type: Number,
      default: 0,
    },
    grandezza: {
      type: String,
      enum: ['piccola', 'media', 'grande', 'extra_large'],
      default: 'media',
    },
    tipo: {
      type: String,
      enum: ['ordini', 'deposito', 'prestito'],
      default: 'deposito',
    },
    peso: {
      type: Number,
      default: 0, // kg
    },
    fotoUrl: {
      type: String,
      default: null,
    },
    operatoreCreatoreId: {
      type: String,
      default: null,
    },
    dataCreazione: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: false, // Usiamo dataCreazione manuale
    collection: 'cella', // Nome collezione MongoDB
  }
);

// Index per ricerca rapida
// cellaId ha già index automatico da unique: true
cellSchema.index({ lockerId: 1 });
cellSchema.index({ stato: 1 });
cellSchema.index({ tipo: 1 });
// Index composto per query frequenti
cellSchema.index({ lockerId: 1, stato: 1 });
cellSchema.index({ lockerId: 1, tipo: 1 });

// Virtual: isAvailable getter
cellSchema.virtual('isAvailable').get(function () {
  return this.stato === 'libera';
});

// Metodo per formattare per frontend
cellSchema.methods.toJSON = function () {
  const cellObject = this.toObject({ virtuals: true });
  return cellObject;
};

// Metodo statico: genera cellaId sequenziale
cellSchema.statics.generateCellaId = async function (lockerId, cellNumber) {
  // Formato: CEL-{lockerId}-{numero}
  // Es. CEL-LCK-001-1, CEL-LCK-001-2
  const lockerIdClean = lockerId.replace('LCK-', ''); // Rimuovi prefisso se presente
  return `CEL-${lockerIdClean}-${cellNumber}`;
};

const Cell = mongoose.model('Cell', cellSchema);

export default Cell;

