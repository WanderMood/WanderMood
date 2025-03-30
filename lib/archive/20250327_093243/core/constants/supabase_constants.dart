class SupabaseConstants {
  // TODO: Vervang deze waarden met je eigen Supabase project credentials
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://asxaybzfkslzbsqmpbjd.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzeGF5Ynpma3NsemJzcW1wYmpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzOTQ1NzYsImV4cCI6MjA1Nzk3MDU3Nn0.dTKzBLI_-kNAAkPFf8_MCvB5lUmwpuwjxJHYZsUYJKM',
  );
} 