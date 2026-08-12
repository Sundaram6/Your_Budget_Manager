enum TransactionType { expense, income }
enum BudgetPeriodType { monthly, weekly }
enum RecurringFrequency { daily, weekly, monthly, yearly }

enum PaymentMethod {
  upi,
  debit_card,
  credit_card,
  cash,
  unknown;

  String get displayName {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.debit_card:
        return 'Debit Card';
      case PaymentMethod.credit_card:
        return 'Credit Card';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.unknown:
        return 'Unknown';
    }
  }

  static PaymentMethod fromString(String? val) {
    if (val == null) return PaymentMethod.unknown;
    switch (val.toLowerCase().trim()) {
      case 'upi':
        return PaymentMethod.upi;
      case 'debit_card':
      case 'debit card':
      case 'debit':
        return PaymentMethod.debit_card;
      case 'credit_card':
      case 'credit card':
      case 'credit':
        return PaymentMethod.credit_card;
      case 'cash':
        return PaymentMethod.cash;
      case 'unknown':
      default:
        return PaymentMethod.unknown;
    }
  }
}
