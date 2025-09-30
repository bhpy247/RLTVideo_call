import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videocall/backend/authentication/authentication_provider.dart';
import 'package:videocall/backend/user_list/user_list_provider.dart';
import 'package:videocall/utils/my_print.dart';
import 'backend/agora/agora_provider.dart';
import 'backend/app_theme/app_theme_provider.dart';
import 'backend/navigation/navigation_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);




  @override
  Widget build(BuildContext context) {
    MyPrint.printOnConsole("MyApp Build Called");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeProvider>(create: (_) => AppThemeProvider(), lazy: false),
        ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider(), lazy: false),
        ChangeNotifierProvider<AgoraProvider>(create: (_) => AgoraProvider(), lazy: false),
        ChangeNotifierProvider<UserListProvider>(create: (_) => UserListProvider(), lazy: false),
      ],
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (BuildContext context, AppThemeProvider appThemeProvider,Widget? child) {
        // MyPrint.printOnConsole("ThemeMode:${appThemeProvider.themeMode}");
        return MaterialApp(

          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationController.mainScreenNavigator,
          title: "Basic Project Structure",
          theme: appThemeProvider.getThemeData(),
          onGenerateRoute: NavigationController.onMainAppGeneratedRoutes,
        );
      },
    );
  }
}

