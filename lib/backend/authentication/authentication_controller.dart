
import 'package:flutter/cupertino.dart';
import 'package:videocall/api/api_controller.dart';
import 'package:videocall/configs/constants.dart';
import 'package:videocall/models/authentication/login_request_model.dart';
import 'package:videocall/models/authentication/login_response_model.dart';
import 'package:videocall/models/common/data_response_model.dart';
import 'package:videocall/utils/extensions.dart';
import 'package:videocall/utils/my_print.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentication_provider.dart';
import 'authentication_repository.dart';

class AuthenticationController {
  late AuthenticationProvider _authenticationProvider;
  late AuthenticationRepository _authenticationRepository;

  AuthenticationController({
    required AuthenticationProvider? authenticationProvider,
    AuthenticationRepository? repository,
  }) {
    _authenticationProvider = authenticationProvider ?? AuthenticationProvider();
    _authenticationRepository = repository ?? AuthenticationRepository(apiController: ApiController());
  }

  AuthenticationProvider get authenticationProvider => _authenticationProvider;

  AuthenticationRepository get authenticationRepository => _authenticationRepository;

  Future<bool> checkIsLoggedIn() async {
    SharedPreferences prefManager = await SharedPreferences.getInstance();
    String? token = prefManager.getString(SharePreferenceKeys.bearerToken);
    MyPrint.printOnConsole("Token : $token");
    if (token == null) return false;

    authenticationRepository.apiController.apiDataProvider.setAuthToken(token);

    return token.checkNotEmpty;
  }

  Future<bool> loginWithEmail({required String email, required String password}) async {
    bool isSuccess = false;

    try {
      EmailLoginRequestModel emailLoginRequestModel = EmailLoginRequestModel(email: email, password: password);
      DataResponseModel<LoginResponseModel> loginResponseModel =
          await authenticationRepository.loginWithEmailAndPassword(login: emailLoginRequestModel);
      MyPrint.printOnConsole("Data: ${loginResponseModel.data?.toJson() ?? " "}");

      if (loginResponseModel.data == null) return false;
      MyPrint.printOnConsole(loginResponseModel.data?.toJson() ?? "");

      if (loginResponseModel.statusCode == 200) {
        String token = loginResponseModel.data?.token ?? "";
        authenticationProvider.loginModel.set(value: loginResponseModel.data);
        MyPrint.printOnConsole("Tokennnn: ${token} ss// ${loginResponseModel.data?.token}");
        if (token.checkNotEmpty) {
          SharedPreferences prefManager = await SharedPreferences.getInstance();
          await prefManager.setString(SharePreferenceKeys.bearerToken, loginResponseModel.data?.token ?? "");
          await prefManager.setString(SharePreferenceKeys.userIdKey, "${loginResponseModel.data?.user?.id}");
          await prefManager.setString(SharePreferenceKeys.userNameKey, "${loginResponseModel.data?.user?.name}");
          authenticationRepository.apiController.apiDataProvider.setAuthToken(token);
        }
        // await getUserModel(userId: loginResponseModel.data?.user?.id ?? "");

        return true;
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AuthenticationController.loginWithEmail $e");
      MyPrint.printOnConsole(s);
    }
    return isSuccess;
  }

  Future<bool> registrationWithEmail({required RegistrationRequestModel requestModel}) async {
    bool isSuccess = false;

    try {
      DataResponseModel<LoginResponseModel> loginResponseModel = await authenticationRepository.registerUser(registerUser: requestModel);
      MyPrint.printOnConsole("Data: ${loginResponseModel.data?.toJson() ?? " "}");

      if (loginResponseModel.data == null) return false;
      MyPrint.printOnConsole(loginResponseModel.data?.toJson() ?? "");

      if (loginResponseModel.statusCode == 201) {
        String token = loginResponseModel.data?.token ?? "";
        authenticationProvider.loginModel.set(value: loginResponseModel.data);
        MyPrint.printOnConsole("Tokennnn: ${token} ss// ${loginResponseModel.data?.token}");
        if (token.checkNotEmpty) {
          SharedPreferences prefManager = await SharedPreferences.getInstance();
          await prefManager.setString(SharePreferenceKeys.bearerToken, loginResponseModel.data?.token ?? "");
          await prefManager.setString(SharePreferenceKeys.userIdKey, "${loginResponseModel.data?.user?.id}");
          await prefManager.setString(SharePreferenceKeys.userNameKey, "${loginResponseModel.data?.user?.name}");
          authenticationRepository.apiController.apiDataProvider.setAuthToken(token);
        }
        // await getUserModel(userId: loginResponseModel.data?.user?.id ?? "");

        return true;
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AuthenticationController.loginWithEmail $e");
      MyPrint.printOnConsole(s);
    }
    return isSuccess;
  }

  // Future<bool> getUserModel({required String userId}) async {
  //   bool isSuccess = false;
  //   if (userId.checkEmpty) return false;
  //   try {
  //     DataResponseModel<UserResponseModel> userResponseModel = await authenticationRepository.getUser(userId);
  //     MyPrint.printOnConsole("Data: ${userResponseModel.data?.toJson() ?? " "}");
  //
  //     if (userResponseModel.data == null) return false;
  //     MyPrint.printOnConsole(userResponseModel.data?.toJson() ?? "");
  //
  //     if (userResponseModel.statusCode == 200) {
  //       authenticationProvider.userModel.set(value: userResponseModel.data?.userModel ?? UserModel());
  //       return true;
  //     }
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in AuthenticationController.getUser $e");
  //     MyPrint.printOnConsole(s);
  //   }
  //   return isSuccess;
  // }
  //
  // Future<bool> createAccount() async {
  //   return false;
  // }
  //
  // Future<void> updateUser({
  //   required UserModel currentUser,
  //   int? level,
  //   int? stars,
  //   int? coinDelta, // Use delta instead of absolute value for more flexibility
  //   int? energyDelta,
  //   Map<String, dynamic>? additionalFields,
  // }) async {
  //   // Calculate new values with null checks
  //   final newLevel = level ?? currentUser.level;
  //   final newStars = stars ?? 0;
  //
  //   // Handle coin changes (add or subtract)
  //   final newCoins = coinDelta != null ? currentUser.coins + coinDelta : currentUser.coins;
  //
  //   // Handle energy changes with minimum protection
  //   final newEnergy = energyDelta != null
  //       ? (currentUser.energy + energyDelta).clamp(0, 100) // Example min/max values
  //       : currentUser.energy;
  //
  //   // Create update model
  //   final updateModel = UpdateUserModel(
  //     newLevel: ParsingHelper.parseIntMethod(newLevel),
  //     newStars: newStars,
  //     id: currentUser.sId,
  //     coins: newCoins,
  //     energy: newEnergy,
  //     // Add any additional fields if provided
  //   );
  //
  //   try {
  //     await updateUserModel(userModel: updateModel);
  //   } catch (e) {
  //     // Consider adding error handling/logging
  //     debugPrint('Failed to update user: $e');
  //     rethrow; // Or handle differently based on your needs
  //   }
  // }
  //
  // Future<bool> updateUserModel({required UpdateUserModel userModel}) async {
  //   bool isSuccess = false;
  //
  //   try {
  //     DataResponseModel<UserResponseModel> userResponseModel = await authenticationRepository.updateUser(updateUser: userModel);
  //     MyPrint.printOnConsole("Data: ${userResponseModel.data?.toJson() ?? " "}");
  //
  //     if (userResponseModel.data == null) return false;
  //     MyPrint.printOnConsole(userResponseModel.data?.toJson() ?? "");
  //
  //     if (userResponseModel.statusCode == 200) {
  //       authenticationProvider.userModel.set(value: userResponseModel.data?.userModel ?? UserModel());
  //       return true;
  //     }
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in AuthenticationController.updateUserModel $e");
  //     MyPrint.printOnConsole(s);
  //   }
  //   return isSuccess;
  // }
  //
  // Future<bool> updateUserModelSingleMap({required Map<String, dynamic> userUpdateMap, required String userId}) async {
  //   bool isSuccess = false;
  //
  //   try {
  //     DataResponseModel<UserResponseModel> userResponseModel =
  //         await authenticationRepository.updateUserOnSingleValues(updateMap: userUpdateMap, userId: userId);
  //     MyPrint.printOnConsole("Data: ${userResponseModel.data?.toJson() ?? " "}");
  //
  //     if (userResponseModel.data == null) return false;
  //     MyPrint.printOnConsole(userResponseModel.data?.toJson() ?? "");
  //
  //     if (userResponseModel.statusCode == 200) {
  //       authenticationProvider.userModel.set(value: userResponseModel.data?.userModel ?? UserModel());
  //       return true;
  //     }
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in AuthenticationController.updateUserModel $e");
  //     MyPrint.printOnConsole(s);
  //   }
  //   return isSuccess;
  // }

  Future<bool> logout(BuildContext context) async {
    SharedPreferences prefManager = await SharedPreferences.getInstance();
    await prefManager.setString(SharePreferenceKeys.bearerToken, '');
    authenticationRepository.apiController.apiDataProvider.setAuthToken("");
    // NavigationController.navigateToLoginScreen(
    //   navigationOperationParameters: NavigationOperationParameters(
    //     context: context,
    //     navigationType: NavigationType.pushNamedAndRemoveUntil,
    //   ),
    // );
    return true;
  }

// Future<bool> isUserLoggedIn() async {
//   AuthenticationProvider provider = authenticationProvider;
//
//   User? firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
//
//   if (firebaseUser == null) {
//     if (kIsWeb) {
//       await Future.delayed(const Duration(seconds: 2));
//       firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
//     }
//   }
//
//   MyPrint.printOnConsole("firebaseUsernammmmmm:${firebaseUser?.displayName}");
//   if (firebaseUser != null && (firebaseUser.phoneNumber ?? "").isNotEmpty) {
//     provider.setAuthenticationDataFromFirebaseUser(
//       firebaseUser: firebaseUser,
//       isNotify: false,
//     );
//     return true;
//   } else {
//     logout();
//     return false;
//   }
// }
//
// Future<bool> checkUserWithIdExistOrNotAndIfNotExistThenCreate({
//   required String userId,
// }) async {
//   String tag = MyUtils.getNewId();
//   MyPrint.printOnConsole("AuthenticationController().checkUserWithIdExistOrNotAndIfNotExistThenCreate() called with userId:'$userId'", tag: tag);
//
//   bool isUserExist = false;
//
//   if (userId.isEmpty) return isUserExist;
//
//   UserController userController = UserController();
//
//   try {
//     UserModel? userModel = await userController.userRepository.getUserModelFromId(userId: userId);
//     MyPrint.printOnConsole("userModel:'$userModel'", tag: tag);
//
//     if (userModel != null) {
//       isUserExist = true;
//
//       authenticationProvider.userModel.set(value: userModel, isNotify: false);
//     } else {
//       UserModel createdUserModel = UserModel(
//         id: userId,
//         mobileNumber: authenticationProvider.mobileNumber.get(),
//       );
//       bool isCreated = await userController.createNewUser(userModel: createdUserModel);
//       MyPrint.printOnConsole("isUserCreated:'$isCreated'", tag: tag);
//
//       if (isCreated) {
//         authenticationProvider.userModel.set(value: createdUserModel, isNotify: false);
//       }
//     }
//   } catch (e, s) {
//     MyPrint.printOnConsole("Error in AuthenticationController().checkUserWithIdExistOrNotAndIfNotExistThenCreate():'$e'", tag: tag);
//     MyPrint.printOnConsole(s, tag: tag);
//   }
//
//   return isUserExist;
// }
//
// //region User Stream Subscription
// // Future<void> startUserSubscription({required CourseProvider courseProvider}) async {
// //   MyPrint.printOnConsole("AuthenticationController().startUserSubscription() called");
// //
// //   AuthenticationProvider provider = authenticationProvider;
// //
// //   String userId = provider.userId.get();
// //
// //   if (userId.trim().isEmpty) {
// //     MyPrint.printOnConsole("Returning from AuthenticationController().startUserSubscription() because userId is empty");
// //     return;
// //   }
// //
// //   Completer<bool> completer = Completer<bool>();
// //   provider.setUserStreamSubscription(
// //     subscription: FirebaseNodes.userDocumentReference(userId: userId).snapshots().listen(
// //       (MyFirestoreDocumentSnapshot snapshot) async {
// //         if (!completer.isCompleted) {
// //           completer.complete(true);
// //         }
// //
// //         UserModel? userModel;
// //         if (snapshot.exists && (snapshot.data() ?? {}).isNotEmpty) {
// //           userModel = UserModel.fromMap(snapshot.data()!);
// //         }
// //
// //         String? notificationToken = await NotificationController().getToken();
// //
// //         if ((userModel?.notificationToken.isNotEmpty ?? false) && (notificationToken?.isNotEmpty ?? false) && userModel!.notificationToken != notificationToken) {
// //           await logout(
// //             isNavigateToLogin: true,
// //             isShowConfirmationDialog: false,
// //             isForceLogout: true,
// //             forceLogoutMessage: "Logging out because Logged In in Another Device",
// //           );
// //           return;
// //         }
// //
// //         //region For Getting Updated MyCourses in Realtime
// //         UserModel? previousUserModel = provider.userModel.get();
// //         bool isGetMyCourses = false;
// //         List<String> myCourseIds = [];
// //
// //         if (userModel != null) {
// //           myCourseIds = userModel.myCoursesData.keys.toList();
// //
// //           if ((previousUserModel == null || !previousUserModel.myCoursesData.keys.toList().isSameListUnOrdered(list: myCourseIds))) {
// //             isGetMyCourses = true;
// //           }
// //         } else {
// //           isGetMyCourses = true;
// //         }
// //
// //         if (isGetMyCourses) {
// //           CourseController courseController = CourseController(provider: courseProvider);
// //           courseController.getMyCoursesList(isRefresh: true, myCourseIds: myCourseIds, isNotify: true);
// //           courseController.getCoursesPaginatedList(
// //             isRefresh: true,
// //             isFromCache: false,
// //             isNotify: true,
// //           );
// //         }
// //         //endregion
// //
// //         provider.userId.set(value: userModel?.id ?? "", isNotify: false);
// //         provider.userModel.set(value: userModel, isNotify: true);
// //       },
// //       onDone: () {
// //         if (!completer.isCompleted) {
// //           completer.complete(true);
// //         }
// //       },
// //       onError: (Object e, StackTrace s) {
// //         if (!completer.isCompleted) {
// //           completer.complete(false);
// //         }
// //       },
// //       cancelOnError: true,
// //     ),
// //     isCancelPreviousSubscription: true,
// //     isNotify: true,
// //   );
// //
// //   await completer.future;
// //
// //   MyPrint.printOnConsole("User Stream Started");
// // }
//
// void stopUserSubscription() async {
//   MyPrint.printOnConsole("AuthenticationController().stopUserSubscription() called");
//
//   AuthenticationProvider provider = authenticationProvider;
//
//   provider.stopUserStreamSubscription(isNotify: false);
//   provider.userId.set(value: "", isNotify: false);
//   provider.userModel.set(value: null, isNotify: true);
// }
//
// //endregion
//
// Future<bool> logout({
//   bool isShowConfirmationDialog = false,
//   bool isNavigateToLogin = false,
//   bool isForceLogout = false,
//   String forceLogoutMessage = "",
// }) async {
//   BuildContext? context = NavigationController.mainScreenNavigator.currentContext;
//
//   bool? isLoggedOut;
//   if (context != null && isShowConfirmationDialog) {
//     isLoggedOut = await showDialog(
//         context: context,
//         builder: (context) {
//           return MyCupertinoAlertDialogWidget(
//             title: "Logout",
//             description: "Are you sure want to logout?",
//             neagtiveText: "No",
//             positiveText: "Yes",
//             negativeCallback: () => Navigator.pop(context, false),
//             positiviCallback: () async {
//               Navigator.pop(context, true);
//             },
//           );
//         });
//   } else {
//     isLoggedOut = true;
//   }
//   MyPrint.printOnConsole("IsLoggedOut:$isLoggedOut");
//
//   if (isLoggedOut != true) {
//     return false;
//   }
//
//   AuthenticationProvider provider = authenticationProvider;
//
//   UserModel? userModel = authenticationProvider.userModel.get();
//   if(userModel != null) UserController().notificationTopicUnSubscriptionOperations(userModel: userModel);
//
//   stopUserSubscription();
//
//   provider.resetData(isNotify: false);
//
//   if (context != null && context.checkMounted() && context.mounted) {
//     // CourseProvider courseProvider = context.read<CourseProvider>();
//     // courseProvider.reset(isNotify: false);
//   }
//
//   try {
//     Future.wait([
//       FirebaseAuth.instance.signOut().then((value) {
//         MyPrint.printOnConsole("Logged Out User From Firebase Auth");
//       }).catchError((e, s) {
//         MyPrint.printOnConsole("Error in Logging Out User From Firebase:$e");
//         MyPrint.printOnConsole(s);
//       }),
//     ]);
//   } catch (e, s) {
//     MyPrint.printOnConsole("Error in Logging Out:$e");
//     MyPrint.printOnConsole(s);
//   }
//
//   isLoggedOut = true;
//
//   if (isNavigateToLogin && context != null && context.checkMounted() && context.mounted) {
//     if (isForceLogout) {
//       Future.delayed(const Duration(seconds: 1), () {
//         if (LoginScreen.context != null) {
//           MyToast.showError(context: LoginScreen.context!, msg: forceLogoutMessage);
//         }
//       });
//     }
//
//     NavigationController.navigateToLoginScreen(
//       navigationOperationParameters: NavigationOperationParameters(
//         context: context,
//         navigationType: NavigationType.pushNamedAndRemoveUntil,
//       ),
//     );
//   }
//
//   return isLoggedOut;
// }
}
