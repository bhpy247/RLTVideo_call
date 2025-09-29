
import 'package:videocall/models/authentication/login_response_model.dart';
import 'package:videocall/models/user_model/user_list_model.dart';

import '../common/common_provider.dart';

class AuthenticationProvider extends CommonProvider {
  AuthenticationProvider() {

    loginModel = CommonProviderPrimitiveParameter<LoginResponseModel?>(
      value: null,
      notify: notify,
    );

    userModel = CommonProviderPrimitiveParameter<UserListModel?>(
      value: null,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
    userName = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<String> userId;
  late CommonProviderPrimitiveParameter<String> userName;
  late CommonProviderPrimitiveParameter<String> mobileNumber;
  late CommonProviderPrimitiveParameter<LoginResponseModel?> loginModel;
  late CommonProviderPrimitiveParameter<UserListModel?> userModel;




  void resetData({bool isNotify = true}) {
    userId.set(value: "", isNotify: false);
    userName.set(value: "", isNotify: false);
    mobileNumber.set(value: "", isNotify: isNotify);
    loginModel.set(value: null, isNotify: isNotify);
    userModel.set(value: null, isNotify: isNotify);
  }
}