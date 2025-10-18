class Karyawan {
  int? id;
  String name;
  String position;
  double baseSalary;
  double allowance;
  double deduction;
  double totalSalary;

  Karyawan({
    this.id,
    required this.name,
    required this.position,
    required this.baseSalary,
    required this.allowance,
    required this.deduction,
    required this.totalSalary,
  });

  // compute total (helper)
  static double computeTotal(double base, double allowance, double deduction) {
    return base + allowance - deduction;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'position': position,
      'baseSalary': baseSalary,
      'allowance': allowance,
      'deduction': deduction,
      'totalSalary': totalSalary,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Karyawan.fromMap(Map<String, dynamic> map) {
    return Karyawan(
      id: map['id'] as int?,
      name: map['name'] as String,
      position: map['position'] as String,
      baseSalary: (map['baseSalary'] as num).toDouble(),
      allowance: (map['allowance'] as num).toDouble(),
      deduction: (map['deduction'] as num).toDouble(),
      totalSalary: (map['totalSalary'] as num).toDouble(),
    );
  }
}
