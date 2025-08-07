import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/views/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vocab_quiz/views/pages/setting_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Global route observer to detect navigation changes throughout the app
  // Used by SettingPage to refresh data when users navigate back from other pages
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vocab Quiz',
      // Register the route observer to enable route change detection
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: authService.value.authStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return SettingPage();
          }
          return HomePage(title: "Vocab Quiz");
        },
      ),
    );
  }
}
