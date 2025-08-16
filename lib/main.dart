import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/home_screen_v2.dart';
import 'screens/saved_quotes_screen_v2.dart';
import 'screens/profile_screen.dart';
import 'screens/att_permission_screen.dart';
import 'services/notification_service.dart';
import 'services/progress_service.dart';
import 'services/challenge_service.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Safely open Hive boxes
  try {
    if (!Hive.isBoxOpen('favorites')) {
      await Hive.openBox('favorites');
    }
    if (!Hive.isBoxOpen('daily_quote')) {
      await Hive.openBox('daily_quote');
    }
    await ProgressService().initialize();
    await ChallengeService().initialize();
  } catch (e) {
    debugPrint('Error opening Hive boxes: $e');
    // Try to delete lock files and retry
    await Hive.deleteBoxFromDisk('favorites');
    await Hive.deleteBoxFromDisk('daily_quote');
    await Hive.deleteBoxFromDisk('user_progress');
    await Hive.deleteBoxFromDisk('challenge_completions');
    
    await Hive.openBox('favorites');
    await Hive.openBox('daily_quote');
    await ProgressService().initialize();
    await ChallengeService().initialize();
  }
  
  // Request App Tracking Transparency permission on iOS
  if (Platform.isIOS) {
    // Wait a moment before showing the ATT prompt
    await Future.delayed(const Duration(milliseconds: 200));
    
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      // Request permission
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
  
  // Initialize Mobile Ads after ATT permission
  MobileAds.instance.initialize();
  
  // Add test device for development
  // Replace with your actual device ID from the console logs
  // MobileAds.instance.updateRequestConfiguration(
  //   RequestConfiguration(testDeviceIds: ['YOUR_TEST_DEVICE_ID']),
  // );
  
  await NotificationService.initialize();
  
  runApp(const RippedForRealApp());
}

class RippedForRealApp extends StatelessWidget {
  const RippedForRealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ripped For Real',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ko'), // Korean
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.3,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const ATTPermissionWrapper(
        child: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreenV2(),
    const SavedQuotesScreenV2(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}