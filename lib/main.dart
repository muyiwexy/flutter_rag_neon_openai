import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neon_rags/core/dependency_injection/injection_container.dart'
    as sl;
import 'package:flutter_neon_rags/features/flutter_rag/presentation/views/base_home_view.dart';
import 'package:flutter_neon_rags/features/flutter_rag/presentation/notifiers/app_notifier.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  await sl.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) =>
            sl.serviceLocator<AppNotifier>()..initPostgresConnection(),
      )
    ],
    child: const Initialize(),
  ));
}

class Initialize extends StatelessWidget {
  const Initialize({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.purple,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          )),
      debugShowCheckedModeBanner: false,
      home: const BaseHomeView(),
    );
  }
}
