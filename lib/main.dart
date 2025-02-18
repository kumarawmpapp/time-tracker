import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'providers/time_entry_provider.dart';
import 'screens/project_management_screen.dart';
import 'screens/home_screen.dart';
import 'screens/task_management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();

  runApp(MyApp(localStorage: localStorage));
}

class MyApp extends StatelessWidget {
  final LocalStorage localStorage;

  const MyApp({Key? key, required this.localStorage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeEntryProvider(localStorage)),
      ],
      child: MaterialApp(
        title: 'Time Entries',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(), // Main entry point, HomeScreen
          '/manage_projects': (context) =>
              ProjectManagementScreen(), // Route for managing projects
          '/manage_tasks': (context) =>
              TaskManagementScreen(), // Route for managing tasks
        },
        // Removed 'home:' since 'initialRoute' is used to define the home route
      ),
    );
  }
}