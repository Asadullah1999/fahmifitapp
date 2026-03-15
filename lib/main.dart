import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'core/database/hive_database.dart';
import 'core/auth/biometric_auth_service.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  // Initialize Hive local database
  await HiveDatabase.initialize();

  runApp(
    const ProviderScope(
      child: DocVaultApp(),
    ),
  );
}
