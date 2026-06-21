import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves the bundled .env asset for a Flutter/Android/iOS flavor name.
String envAssetForFlavor(String flavor) {
  switch (flavor) {
    case 'trackauthoritymusic':
    case 'tam':
      return '.env.tam';
    default:
      return '.env.$flavor';
  }
}

/// Loads brand config from a bundled .env asset.
/// Pass `--dart-define=FLAVOR=<flavor>` matching `--flavor <flavor>`.
Future<void> loadEnvForFlavor() async {
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'trackauthoritymusic');
  await dotenv.load(fileName: envAssetForFlavor(flavor));
}

String env(String key, {String fallback = ''}) {
  return dotenv.get(key, fallback: fallback);
}
