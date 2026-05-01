import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smartq/viewmodels/admin_viewmodel.dart';
import 'package:smartq/viewmodels/doctor_viewmodel.dart';
import 'package:smartq/viewmodels/notification_viewmodel.dart';
import 'package:smartq/viewmodels/queue_status_viewmodel.dart';
import 'package:smartq/viewmodels/queue_viewmodel.dart';
import 'package:smartq/viewmodels/auth_viewmodel.dart';
import 'package:smartq/viewmodels/profile_viewmodel.dart';
import 'package:smartq/viewmodels/ticket_viewmodel.dart';
import 'theme_provider.dart';
import 'firebase_options.dart';
import 'views/user/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> ThemeProvider()),
        ChangeNotifierProvider(create: (_) =>AuthViewModel()),
        ChangeNotifierProvider(create: (_)=> AdminViewModel()),
        ChangeNotifierProvider(create: (_)=> DoctorViewModel()),
        ChangeNotifierProvider(create: (_)=> QueueViewModel()),
        ChangeNotifierProvider(create: (_)=> QueueStatusViewModel()),
        ChangeNotifierProvider(create: (_)=> ProfileViewModel()),
        ChangeNotifierProvider(create: (_)=> NotificationViewModel()),
        ChangeNotifierProvider(create: (_)=> TicketViewModel()),
      ],
    child: const SmartQApp(),
    ),
  );
}

class SmartQApp extends StatelessWidget {
  const SmartQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}