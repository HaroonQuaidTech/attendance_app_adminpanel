import 'package:flutter/material.dart';
import 'package:quaidtech/screens/Checkin.dart';
import 'package:quaidtech/screens/home.dart';
import 'package:quaidtech/screens/login.dart';
import 'package:quaidtech/screens/adminhome.dart';
import 'package:quaidtech/screens/newscreen.dart';
import 'package:quaidtech/screens/notification.dart';
import 'package:quaidtech/screens/profile.dart';
import 'package:quaidtech/screens/signup.dart';
import 'package:quaidtech/screens/splashscreen.dart';
import 'package:quaidtech/screens/stastics.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: "KumbhSans"),
        initialRoute: 'adminh',
        routes: {
          'login': (context) => const LoginScreen(),
          'signup': (context) => const SignUpScreen(),
          'nscreen': (context) => const Newscreen(),
          'home': (context) => const HomeScreen(),
          'checkin': (context) => const CheckinScreen(),
          'notification': (context) => const NotificationScreen(),
          'profile': (context) => const ProfileScreen(),
          'stat': (context) => const StatsticsScreen(),
          'adminh': (context) => const AdminHomeScreen(),
          'splash': (context) => const Splashscreen(),
        
        },
      ),
    );
  }
}
