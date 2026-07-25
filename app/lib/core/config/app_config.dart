class AppConfig {
  static const String _supabaseUrl = String.fromEnvironment(
    'NEXT_PUBLIC_SUPABASE_URL',
    defaultValue: 'https://eqescqsxjrrmjzbdtzbt.supabase.co',
  );

  static const String _supabaseAnonKey = String.fromEnvironment(
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxZXNjcXN4anJybWp6YmR0emJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MzM3OTQsImV4cCI6MjA5NjIwOTc5NH0.kgmOFf_Q8Gn_30qSiuCxhfaeWGe7yMyWIUF0jT67bxk',
  );

  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mindful-consistent-us.vercel.app',
  );

  static const String _razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_live_bwAd15SKh2A6Ji',
  );

  static String get supabaseUrl => _supabaseUrl;
  static String get supabaseAnonKey => _supabaseAnonKey;
  static String get apiBaseUrl => _apiBaseUrl;
  static String get razorpayKeyId => _razorpayKeyId;

  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );
}
