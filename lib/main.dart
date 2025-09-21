import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 📌 Routes
import 'routes/app_routes.dart';

// 📌 Services
import 'services/notification_service.dart';
import 'services/realtime_listener.dart';

// 📌 Screens
import 'features/ai/screens/ai_screen.dart';
import 'screens/settings/account/change_email_screen.dart';
import 'screens/settings/account/change_phone_screen.dart';
import 'screens/settings/account/two_factor_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables
  await dotenv.load(fileName: ".env");

  // Debug logs (remove in production)
  if (kDebugMode) {
    print("🔐 Supabase URL: ${dotenv.env['SUPABASE_URL']}");
    print("🔐 Supabase Key: ${dotenv.env['SUPABASE_ANON_KEY']}");
    print("🤖 Gemini API Key Loaded: ${dotenv.env['API_KEY'] != null}");
  }

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ✅ Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  // ✅ Request permissions (mobile & web)
  await notificationService.requestPermissions();

  // ✅ Start real-time notifications listener
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
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),

      // ✅ Initial route
      initialRoute: AppRoutes.welcome,

      // ✅ Registered routes
      routes: {
        ...AppRoutes.routes, // existing routes

        // Extra screens for account settings
        AppRoutes.changeEmail: (context) => const ChangeEmailScreen(),
        AppRoutes.changePhone: (context) => const ChangePhoneScreen(),
        AppRoutes.twoFactorSetup: (context) => const TwoFactorSetupScreen(),

        // AI route
        '/ai': (context) => const AIScreen(),
      },
    );
  }
}
