import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videocall/backend/authentication/authentication_controller.dart';
import 'package:videocall/backend/authentication/authentication_provider.dart';
import 'package:videocall/configs/constants.dart';
import 'package:videocall/models/authentication/login_response_model.dart';
import 'package:videocall/models/user_model/user_list_model.dart';
import 'package:videocall/utils/extensions.dart';
import 'package:videocall/utils/my_print.dart';
import 'package:videocall/views/user/user_list_screen.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/app_colors.dart';
import '../../../utils/shared_pref_manager.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late ThemeData themeData;
  late AuthenticationController authenticationController;
  late AuthenticationProvider authenticationProvider;


  Future<void> checkLogin({required bool isCheckAuthentication}) async {
    await Future.delayed(const Duration(seconds: 3));
    SharedPrefManager prefManager = SharedPrefManager();

    if (context.checkMounted() && context.mounted) {
      bool isLogin = await authenticationController.checkIsLoggedIn();

      if (isLogin) {
        String useModelString = await prefManager.getString(SharePreferenceKeys.userIdKey) ?? "";
        String userId = await prefManager.getString(SharePreferenceKeys.userIdKey) ?? "";
        String userName = await prefManager.getString(SharePreferenceKeys.userIdKey) ?? "";
        MyPrint.printOnConsole("useModelString :  $useModelString");



        if(userId.checkNotEmpty) {


          LoginResponseModel userResponseModel = LoginResponseModel(user: User(name: userName, id: userId));
          AuthenticationProvider provider = context.read<AuthenticationProvider>();
          provider.userName.set(value: userResponseModel.user?.name ?? "");
          provider.userId.set(value: userResponseModel.user?.id ?? "");
          // await authenticationController.getUserModel(userId: userId);
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => UserListScreen()));

        } else {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => UserListScreen()));
          //Todo: Add Navigation For the login screen
          // NavigationController.navigateToLoginScreen(
          //   navigationOperationParameters: NavigationOperationParameters(
          //     context: context,
          //     navigationType: NavigationType.pushNamedAndRemoveUntil,
          //   ),
          // );
        }
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => UserListScreen()));

        //Todo: Add Navigation For the login screen

        // NavigationController.navigateToLoginScreen(
        //   navigationOperationParameters: NavigationOperationParameters(
        //     context: context,
        //     navigationType: NavigationType.pushNamedAndRemoveUntil,
        //   ),
        // );
      }
    }
  }





  @override
  void initState() {
    super.initState();
    authenticationProvider = context.read<AuthenticationProvider>();
    authenticationController = AuthenticationController(authenticationProvider: authenticationProvider);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)  {
      NavigationController.isFirst = false;
      checkLogin(isCheckAuthentication: !kIsWeb);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text("Splash Screen"))
    );
  }
}
