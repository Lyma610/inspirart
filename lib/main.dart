import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_screens/home_screen.dart';
import 'screens/main_screens/search_screen.dart';
import 'screens/main_screens/post_screen.dart';
import 'screens/main_screens/notifications_screen.dart';
import 'screens/main_screens/profile_screen.dart';
import 'screens/main_screens/user_profile_screen.dart';
import 'screens/post/create_post_screen.dart';
import 'screens/post/select_media_screen.dart';
import 'screens/post/choose_category_screen.dart';
import 'screens/post/sequences_screen.dart';
import 'screens/followers/followers_screen.dart';
import 'screens/main_screens/edit_profile_screen.dart';
import 'screens/main_screens/notification_settings_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/main_screens/settings_screen.dart';
import 'screens/main_screens/history_screen.dart';
import 'screens/main_screens/saved_posts_screen.dart';
import 'screens/main_screens/help_screen.dart';
import 'screens/discover/discover_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const InspirartApp());
}

class InspirartApp extends StatelessWidget {
  const InspirartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp.router(
        title: 'Inspirart',
        theme: AppTheme.theme,
        darkTheme: AppTheme.theme,
        themeMode: ThemeMode.dark,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => SearchScreen(),
    ),
    GoRoute(
      path: '/post/:postId',
      builder: (context, state) => PostScreen(
        postId: state.pathParameters['postId']!,
      ),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileScreen(),
    ),
    GoRoute(
      path: '/user/:userId',
      builder: (context, state) => UserProfileScreen(
        userId: state.pathParameters['userId']!,
      ),
    ),
    GoRoute(
      path: '/create-post',
      builder: (context, state) => CreatePostScreen(),
    ),
    GoRoute(
      path: '/select-media',
      builder: (context, state) => SelectMediaScreen(),
    ),
    GoRoute(
      path: '/choose-category',
      builder: (context, state) => ChooseCategoryScreen(),
    ),
    GoRoute(
      path: '/sequences',
      builder: (context, state) => SequencesScreen(),
    ),
    GoRoute(
      path: '/followers',
      builder: (context, state) => FollowersScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/chat/:userId',
      builder: (context, state) => ChatScreen(
        userId: state.pathParameters['userId']!,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/saved-posts',
      builder: (context, state) => const SavedPostsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/discover',
      builder: (context, state) => const DiscoverScreen(),
    ),
  ],
);
