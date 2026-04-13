class ZakatThreshold {
  final String? id;
  final String title;
  final String amount;
  final int order;

  ZakatThreshold({
    this.id,
    required this.title,
    required this.amount,
    required this.order,
  });

  factory ZakatThreshold.fromFirestore(Map<String, dynamic> data) {
    return ZakatThreshold(
      id: data['id'],
      title: data['title'] ?? '',
      amount: data['amount'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}

