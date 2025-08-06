import 'package:flutter/material.dart';

// 🔐 Auth Screens
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/student_register_screen.dart';
import '../features/auth/screens/admin_register_screen.dart';
import '../features/auth/screens/staff_register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';

// 🚀 Welcome & Home
import '../features/welcome/screens/welcome_screen.dart';
import '../features/home/screens/home_screen.dart';

// 📝 Post Screens
import '../features/posts/screens/create_post_screen.dart';
import '../screens/post/post_detail_screen.dart';

// ⚙️ Core Standalone Screens
import '../screens/settings/settings_screen.dart';
import '../screens/comments/comments_screen.dart';
import '../screens/share/share_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';

// 🤖 AI Assistant Screen
import '../features/ai/screens/ai_screen.dart'; // ✅ Ensure file exists

class AppRoutes {
  // 🌐 Named route constants
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String adminRegister = '/admin-register';
  static const String staffRegister = '/staff-register';
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  static const String settings = '/settings';
  static const String comments = '/comments';
  static const String share = '/share';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String aiAssistant = '/ai-assistant';

  // 🗺 Route map
  static final Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    home: (context) => const HomeScreen(),
    adminRegister: (context) => const AdminRegisterScreen(),
    staffRegister: (context) => const StaffRegisterScreen(),
    createPost: (context) => const CreatePostScreen(),
    postDetail: (context) => const PostDetailScreen(),
    settings: (context) => const SettingsScreen(),
    comments: (context) => const CommentsScreen(),
    share: (context) => const ShareScreen(),
    notifications: (context) => const NotificationsScreen(),
    profile: (context) => const ProfileScreen(),
    aiAssistant: (context) => const AIScreen(), // ✅ Clean usage now!
  };
}
