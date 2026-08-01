class AppConstants {
  AppConstants._();

  static const String appVersion = '1.0.0';
  static const String dbFilename = 'ybm_data.sqlite';
  static const int backupFormatVersion = 1;
  
  static const List<int> allowedPinLengths = [4, 6];
  static const Duration autoLockTimeout = Duration(minutes: 5);
  static const int pbkdf2Iterations = 10000;
}
