class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Invalid amount';
    }
    if (number <= 0) {
      return 'Amount must be greater than zero';
    }
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (value.length != 4 && value.length != 6) {
      return 'PIN must be 4 or 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only numbers';
    }
    return null;
  }

  static String? passphrase(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Passphrase is required';
    }
    if (value.length < 8) {
      return 'Passphrase must be at least 8 characters long';
    }
    return null;
  }
}
