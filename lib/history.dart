class History {
  final int id;
  final String expression;
  final double result;
  final DateTime createdAt;

  History({
    required this.id,
    required this.expression,
    required this.result,
    required this.createdAt,
  });

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],
      expression: map['expression'],
      result: map['result'],
      createdAt: DateTime.parse(map['Created_at']),
    );
  }
}
