class AppConstants {
  // Set to false for live Supabase Cloud; true for fallback offline demo
  static const bool useMockData = bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false);

  // Supabase Credentials (configured via environment or defaults)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy',
  );

  // Matching Thresholds
  static const double mutualMatchThreshold = 68.0;
  static const double superlikeBoost = 15.0;
  static const double dealbreakerScoreCap = 25.0;

  // Safety Protocol
  static const String coffeeMeetupSafetyNotice =
      'Safety First: Always meet in a daylight, busy public cafe before visiting any private apartment.';
}
