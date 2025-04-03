class CattleConstants {
  static const List<String> breeds = [
    'Holstein',
    'Angus',
    'Hereford',
    'Jersey',
    'Brahman',
    'Simmental',
    'Charolais',
    'Limousin',
    'Gelbvieh',
    'Shorthorn',
    'Aberdeen Angus',
    'Ayrshire',
    'Brangus',
    'Brown Swiss',
    'Guernsey',
    'Other'
  ];

  static const List<String> genders = [
    'Female',
    'Male',
  ];

  static const Map<String, String> cattleCategories = {
    'dairy': 'Dairy Cattle',
    'beef': 'Beef Cattle',
    'dual': 'Dual Purpose',
    'breeding': 'Breeding Stock',
    'calf': 'Calves',
  };
}

class FeedConstants {
  static const List<String> feedTypes = [
    'Hay',
    'Silage',
    'Grain',
    'Concentrate',
    'Mineral Mix',
    'Salt Block',
    'Pasture',
    'Fodder',
    'Other'
  ];
  
  static const List<String> quantityUnits = [
    'kg',
    'bags',
    'bales',
    'tons',
    'units'
  ];
} 