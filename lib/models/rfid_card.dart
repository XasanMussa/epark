class RFIDCard {
  final String cardNumber;
  final String ownerName;
  final String phoneNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String packageName;
  final int amountPaid;
  final bool isActive;
  final String status;

  RFIDCard({
    required this.cardNumber,
    required this.ownerName,
    required this.phoneNumber,
    required this.startDate,
    required this.endDate,
    required this.packageName,
    required this.amountPaid,
    required this.isActive,
    required this.status,
  });
}
