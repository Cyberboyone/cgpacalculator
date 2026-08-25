import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ad_service.dart';
import 'services/app_state.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.init(); // safe no-op offline; ads simply fail to load without network
  runApp(const GpaApp());
}

class GpaApp extends StatelessWidget {
  const GpaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: MaterialApp(
        title: 'GPA Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF3D5AFE),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
