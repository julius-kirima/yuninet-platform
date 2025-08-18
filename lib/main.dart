import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_routes.dart';
import 'services/notification_service.dart';
import 'services/realtime_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from assets/.env
  await dotenv.load(fileName: "assets/.env");

  // Debug logs (remove in production)
  print("🔐 Supabase URL: ${dotenv.env['SUPABASE_URL']}");
  print("🔐 Supabase Key: ${dotenv.env['SUPABASE_ANON_KEY']}");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  // Request permissions on mobile platforms
  if (!kIsWeb) {
    await notificationService.requestPermissions();
  } else {
    // Request browser notification permission on Web
    await notificationService.requestPermissions();
  }

  // Start real-time notifications listener
  startNotificationListener();

  runApp(const YuninetApp());
}

class YuninetApp extends StatelessWidget {
  const YuninetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yuninet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
