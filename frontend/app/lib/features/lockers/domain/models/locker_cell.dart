import 'package:app/features/lockers/domain/models/cell_type.dart';

/// Modello per una cella specifica in un locker
/// 
/// Rappresenta una singola cella con le sue caratteristiche
class LockerCell {
  final String id;
  final String cellNumber; // Es. "Cella 1", "Cella A-3"
  final CellType type;
  final CellSize size; // Dimensione della cella
  final bool isAvailable;
  final String? itemName; // Nome dell'oggetto (se tipo borrow o pickup)
  final String? itemDescription; // Descrizione dell'oggetto
  final String? itemImageUrl; // URL immagine oggetto (se disponibile)
  final double pricePerHour; // Prezzo per ora (basato sulla dimensione)
  final double pricePerDay; // Prezzo per giorno (basato sulla dimensione)
  final String? storeName; // Nome del negozio (se tipo pickup)
  final DateTime? availableUntil; // Fino a quando è disponibile (per pickup)
  final Duration? borrowDuration; // Durata del prestito (se tipo borrow)

  const LockerCell({
    required this.id,
    required this.cellNumber,
    required this.type,
    required this.size,
    required this.isAvailable,
    required this.pricePerHour,
    required this.pricePerDay,
    this.itemName,
    this.itemDescription,
    this.itemImageUrl,
    this.storeName,
    this.availableUntil,
    this.borrowDuration, // Durata predefinita per il prestito (es. 7 giorni)
  });

  /// Crea un'istanza da JSON (risposta backend)
  factory LockerCell.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final type = CellType.fromString(typeString) ?? CellType.deposit;

    final sizeString = json['size'] as String?;
    final size = CellSize.fromString(sizeString) ?? CellSize.medium;

    return LockerCell(
      id: json['id'] as String,
      cellNumber: json['cellNumber'] as String? ?? json['cell_number'] as String? ?? '',
      type: type,
      size: size,
      isAvailable: json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? false,
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      itemName: json['itemName'] as String?,
      itemDescription: json['itemDescription'] as String?,
      itemImageUrl: json['itemImageUrl'] as String?,
      storeName: json['storeName'] as String?,
      availableUntil: json['availableUntil'] != null
          ? DateTime.tryParse(json['availableUntil'] as String)
          : null,
    );
  }
}

/// Statistiche delle celle disponibili per tipo in un locker
class LockerCellStats {
  final int totalCells;
  final int availableBorrowCells; // Celle con oggetti da prendere in prestito
  final int availableDepositCells; // Celle vuote per depositare
  final int availablePickupCells; // Celle con prodotti da ritirare

  const LockerCellStats({
    required this.totalCells,
    required this.availableBorrowCells,
    required this.availableDepositCells,
    required this.availablePickupCells,
  });

  int get totalAvailable => availableBorrowCells + availableDepositCells + availablePickupCells;

  /// Crea un'istanza da JSON (risposta backend)
  factory LockerCellStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? json;
    
    return LockerCellStats(
      totalCells: stats['totalCells'] as int? ?? 0,
      availableBorrowCells: stats['availableBorrowCells'] as int? ?? 0,
      availableDepositCells: stats['availableDepositCells'] as int? ?? 0,
      availablePickupCells: stats['availablePickupCells'] as int? ?? 0,
    );
  }
}

