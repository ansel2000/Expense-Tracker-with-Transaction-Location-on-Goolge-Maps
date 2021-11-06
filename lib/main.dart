// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

// providers
import 'services/google_sheets_provider.dart';
import 'services/location_provider.dart';

// screens
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';

final _notifications = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initSettingAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initSettings = InitializationSettings(initSettingAndroid, null);

  await _notifications.initialize(initSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => GoogleSheetsProvider(),
          lazy: false,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Expense Tracker",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        backgroundColor: Colors.grey[300],
        canvasColor: Colors.grey[300],
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Colors.grey[600],
            ),
          ),
        ),
      ),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        MapScreen.routeName: (context) => MapScreen(),
      },
    );
  }
}
