/// Units are never added into one number (SA-15). Kilogram equivalents are
/// shown only where a conversion exists (bag needs a crop bag weight).
enum QtyUnit { kg, bag, quintal, tonne }

extension QtyUnitX on QtyUnit {
  String get key => 'unit_$name';
}

/// Sample master data. In production this comes from the admin web (kg per bag per crop).
final Map<String, double> bagWeightKg = {
  'Paddy': 75,
  'Groundnut': 40,
  'Maize': 50,
  'Turmeric': 50,
  'Black gram': 50,
};

const List<String> cropList = ['Paddy', 'Groundnut', 'Maize', 'Turmeric', 'Banana', 'Sugarcane', 'Cotton', 'Black gram'];
const List<String> districtList = [
  'Thanjavur', 'Tiruvarur', 'Nagapattinam', 'Trichy', 'Madurai', 'Erode',
  'Salem', 'Coimbatore', 'Villupuram', 'Cuddalore', 'Tirunelveli', 'Chengalpattu'
];

double? toKg(double qty, QtyUnit unit, String crop) {
  switch (unit) {
    case QtyUnit.kg:
      return qty;
    case QtyUnit.quintal:
      return qty * 100;
    case QtyUnit.tonne:
      return qty * 1000;
    case QtyUnit.bag:
      final w = bagWeightKg[crop];
      return w == null ? null : qty * w;
  }
}

String fmtNum(double v) {
  final s = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  final parts = s.split('.');
  final grouped = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
}

String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

String fmtTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
