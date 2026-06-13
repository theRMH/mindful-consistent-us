class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'NEXT_PUBLIC_SUPABASE_URL',
    defaultValue: 'https://eqescqsxjrrmjzbdtzbt.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxZXNjcXN4anJybWp6YmR0emJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MzM3OTQsImV4cCI6MjA5NjIwOTc5NH0.kgmOFf_Q8Gn_30qSiuCxhfaeWGe7yMyWIUF0jT67bxk',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mindful-consistent-us.vercel.app',
  );

  // Set to false — app now runs against real backend. Re-enable only for UI-only work without backend.
  static const bool useMockData = false;
}
