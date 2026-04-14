enum AppEnvironment {
  dev,
  prod,
}

class AppConfig {
  final AppEnvironment environment;
  final String firebaseApiKey;
  final String firebaseProjectId;
  final String firebaseMessagingSenderId;
  final String firebaseAppId;
  final int maxBorrowDaysLogged;
  final int maxBorrowDaysExternal;

  const AppConfig({
    required this.environment,
    required this.firebaseApiKey,
    required this.firebaseProjectId,
    required this.firebaseMessagingSenderId,
    required this.firebaseAppId,
    this.maxBorrowDaysLogged = 14,
    this.maxBorrowDaysExternal = 7,
  });

  bool get isDevelopment => environment == AppEnvironment.dev;
  bool get isProduction => environment == AppEnvironment.prod;

  static AppConfig get dev => const AppConfig(
        environment: AppEnvironment.dev,
        firebaseApiKey: 'DEV_API_KEY',
        firebaseProjectId: 'csfm-library-dev',
        firebaseMessagingSenderId: '000000000000',
        firebaseAppId: '1:000000000000:android:dev',
      );

  static AppConfig get prod => const AppConfig(
        environment: AppEnvironment.prod,
        firebaseApiKey: 'PROD_API_KEY',
        firebaseProjectId: 'csfm-library-prod',
        firebaseMessagingSenderId: '000000000000',
        firebaseAppId: '1:000000000000:android:prod',
      );
}
