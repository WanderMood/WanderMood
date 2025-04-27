class Logger {
  static void error(String message) {
    // In production, you might want to use a proper logging service
    print('🔴 ERROR: $message');
  }

  static void info(String message) {
    print('ℹ️ INFO: $message');
  }

  static void warning(String message) {
    print('⚠️ WARNING: $message');
  }
} 