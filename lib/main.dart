import 'package:flutter/material.dart';
import 'package:fomal_specification/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //required to use platform channels to call native code.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool themeBool = prefs.getBool("isDark") ?? false; //null check
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) => ThemeProvider(isDark: themeBool),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Wrapping MaterialApp with Consumer makes the ThemeProvider available throughout the app.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: themeProvider.getTheme,
          home: const HomePage(),
        );
      },
    );
  }
}
