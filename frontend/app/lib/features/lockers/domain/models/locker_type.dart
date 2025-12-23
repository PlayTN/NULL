import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

enum LockerType {
  sportivi('Sportivi', CupertinoIcons.sportscourt_fill),
  personali('Personali', CupertinoIcons.bag_fill),
  petFriendly('Pet-Friendly', CupertinoIcons.heart_fill),
  commerciali('Commerciali', CupertinoIcons.cart_fill),
  cicloturistici('Cicloturistici', CupertinoIcons.location_fill);

  final String label;
  final IconData icon;

  const LockerType(this.label, this.icon);

  /// Converte una stringa del backend in LockerType
  static LockerType? fromString(String? value) {
    if (value == null) return null;
    
    switch (value.toLowerCase()) {
      case 'sportivi':
        return LockerType.sportivi;
      case 'personali':
        return LockerType.personali;
      case 'petfriendly':
      case 'pet-friendly':
        return LockerType.petFriendly;
      case 'commerciali':
        return LockerType.commerciali;
      case 'cicloturistici':
        return LockerType.cicloturistici;
      default:
        return null;
    }
  }
}

