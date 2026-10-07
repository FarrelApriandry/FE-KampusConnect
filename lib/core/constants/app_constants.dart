/// Global app constants (KampusConnect).
///
/// `API_BASE_URL` bisa di-override saat build:
///   flutter run --dart-define=API_BASE_URL=https://kampusconnect-api.example.com
/// Default = 10.0.2.2 (Android emulator → localhost) port 3000 (ElysiaJS default).
library;

const String appName = 'KampusConnect';
const String appTagline = 'Jual-beli aman antar mahasiswa';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

const Duration apiConnectTimeout = Duration(seconds: 20);
const Duration apiReceiveTimeout = Duration(seconds: 20);
const Duration apiSendTimeout = Duration(seconds: 20);

/// Storage keys
const String kTokenKey = 'kc_access_token';
const String kUserKey = 'kc_user';