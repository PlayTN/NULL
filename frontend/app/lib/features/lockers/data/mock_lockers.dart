import 'package:latlong2/latlong.dart';
import 'package:app/features/lockers/domain/models/locker.dart';
import 'package:app/features/lockers/domain/models/locker_type.dart';

// Mock data per i lockers a Trento (posizioni di esempio - distribuite nel centro)
final List<Locker> mockLockers = [
  // Lockers Sportivi nei parchi
  Locker(
    id: 'sport-001',
    name: 'Parco delle Albere',
    position: const LatLng(46.0820, 11.1320), // Nord-est, Parco delle Albere
    type: LockerType.sportivi,
    totalCells: 12,
    availableCells: 8,
    description: 'Attrezzature sportive e ricreative',
  ),
  // Lockers Personali
  Locker(
    id: 'pers-001',
    name: 'Centro Storico - Piazza Duomo',
    position: const LatLng(46.0700, 11.1200), // Centro esatto, Piazza Duomo
    type: LockerType.personali,
    totalCells: 20,
    availableCells: 15,
    description: 'Deposito effetti personali',
  ),
  Locker(
    id: 'pers-002',
    name: 'Stazione FS',
    position: const LatLng(46.0750, 11.1250), // Nord-est, Stazione Ferroviaria
    type: LockerType.personali,
    totalCells: 30,
    availableCells: 22,
  ),
  // Lockers Pet-Friendly
  Locker(
    id: 'pet-001',
    name: 'Area Cani - Parco Fersina',
    position: const LatLng(46.0580, 11.1080), // Sud-ovest, Parco Fersina
    type: LockerType.petFriendly,
    totalCells: 8,
    availableCells: 6,
    description: 'Ciotole, giochi e sacchetti igienici',
  ),
  // Lockers Commerciali
  Locker(
    id: 'comm-001',
    name: 'Via Manci',
    position: const LatLng(46.0680, 11.1180), // Centro-ovest, Via Manci
    type: LockerType.commerciali,
    totalCells: 15,
    availableCells: 10,
    description: 'Ritiro prodotti locali',
  ),
  // Lockers Cicloturistici
  Locker(
    id: 'bike-001',
    name: 'Pista Ciclabile Adige',
    position: const LatLng(46.0650, 11.1280), // Est, lungo il fiume Adige
    type: LockerType.cicloturistici,
    totalCells: 6,
    availableCells: 4,
    description: 'Attrezzi manutenzione bici',
  ),
];


