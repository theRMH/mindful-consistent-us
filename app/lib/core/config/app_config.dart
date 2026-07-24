class AppConfig {
  static const String _supabaseUrl = String.fromEnvironment(
    'NEXT_PUBLIC_SUPABASE_URL',
  );

  static const String _supabaseAnonKey = String.fromEnvironment(
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  );

  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const String _razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
  );

  static String get supabaseUrl =>
      _required(_supabaseUrl, 'NEXT_PUBLIC_SUPABASE_URL');

  static String get supabaseAnonKey =>
      _required(_supabaseAnonKey, 'NEXT_PUBLIC_SUPABASE_ANON_KEY');

  static String get apiBaseUrl => _required(_apiBaseUrl, 'API_BASE_URL');

  // Razorpay key id is public, but it is still environment-specific.
  static String get razorpayKeyId =>
      _required(_razorpayKeyId, 'RAZORPAY_KEY_ID');

  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );

  static String _required(String value, String name) {
    if (value.trim().isEmpty) {
      throw StateError('$name must be provided with --dart-define');
    }
    return value;
  }
}
