import 'package:videocall/models/authentication/login_response_model.dart';
import 'package:videocall/models/user_model/user_list_model.dart';

import '../../api/api_call_model.dart';
import '../../api/api_controller.dart';
import '../../api/api_endpoints.dart';
import '../../api/rest_client.dart';
import '../../models/authentication/login_request_model.dart';
import '../../models/common/data_response_model.dart';
import '../../models/common/model_data_parser.dart';
import '../../models/user_model/update_user_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class AuthenticationRepository {
  final ApiController apiController;

  const AuthenticationRepository({required this.apiController});

  Future<DataResponseModel<LoginResponseModel>> loginWithEmailAndPassword(
      {required EmailLoginRequestModel login}) async {
    ApiEndpoints apiEndpoints = apiController.apiEndpoints;

    MyPrint.printOnConsole("Site Url:${apiEndpoints.siteUrl}");

    ApiCallModel apiCallModel =
        await apiController.getApiCallModelFromData<String>(
      restCallType: RestCallType.simplePostCall,
      parsingType: ModelDataParsingType.loginModel,
      url: apiEndpoints.apiPostLoginDetails(),
      requestBody: MyUtils.encodeJson(login.toJson()),
      isAuthenticatedApiCall: false,
    );

    DataResponseModel<LoginResponseModel> apiResponseModel =
        await apiController.callApi<LoginResponseModel>(
      apiCallModel: apiCallModel,
    );
    return apiResponseModel;
  }

  Future<DataResponseModel<LoginResponseModel>> registerUser(
      {required RegistrationRequestModel registerUser}) async {
    ApiEndpoints apiEndpoints = apiController.apiEndpoints;

    MyPrint.printOnConsole("Site Url:${apiEndpoints.siteUrl}");

    ApiCallModel apiCallModel =
    await apiController.getApiCallModelFromData<String>(
      restCallType: RestCallType.simplePostCall,
      parsingType: ModelDataParsingType.loginModel,
      url: apiEndpoints.apiRegisterUser(),
      requestBody: MyUtils.encodeJson(registerUser.toJson()),
      isAuthenticatedApiCall: false,

    );

    DataResponseModel<LoginResponseModel> apiResponseModel =
    await apiController.callApi<LoginResponseModel>(
      apiCallModel: apiCallModel,
    );
    return apiResponseModel;
  }

  Future<DataResponseModel<UserListModel>> getUser(String userId) async {
    ApiEndpoints apiEndpoints = apiController.apiEndpoints;

    MyPrint.printOnConsole("Site Url:${apiController.apiDataProvider.getAuthToken()}");

    ApiCallModel apiCallModel =
        await apiController.getApiCallModelFromData<String>(
      restCallType: RestCallType.simpleGetCall,
      parsingType: ModelDataParsingType.userModel,
      url: apiEndpoints.apiGetUser(userId),
      isAuthenticatedApiCall: true,
      token: apiController.apiDataProvider.getAuthToken(),
    );

    DataResponseModel<UserListModel> apiResponseModel =
        await apiController.callApi<UserListModel>(
      apiCallModel: apiCallModel,
    );

    return apiResponseModel;
  }

  Future<DataResponseModel<UserListModel>> updateUser(
      {required UpdateUserModel updateUser}) async {
    ApiEndpoints apiEndpoints = apiController.apiEndpoints;

    MyPrint.printOnConsole("Site Url:${apiEndpoints.siteUrl}");

    ApiCallModel apiCallModel =
    await apiController.getApiCallModelFromData<String>(
      restCallType: RestCallType.simplePatchCall,
      parsingType: ModelDataParsingType.userModel,
      url: apiEndpoints.apiUpdateUser(updateUser.id),
      requestBody: MyUtils.encodeJson(updateUser.toJson()),
      isAuthenticatedApiCall: true,
    );

    DataResponseModel<UserListModel> apiResponseModel =
    await apiController.callApi<UserListModel>(
      apiCallModel: apiCallModel,
    );
    return apiResponseModel;
  }

  Future<DataResponseModel<UserListModel>> updateUserOnSingleValues(
      {required Map<String,dynamic> updateMap, required String userId}) async {
    ApiEndpoints apiEndpoints = apiController.apiEndpoints;

    MyPrint.printOnConsole("Site Url:${apiEndpoints.siteUrl}");

    ApiCallModel apiCallModel =
    await apiController.getApiCallModelFromData<String>(
      restCallType: RestCallType.simplePatchCall,
      parsingType: ModelDataParsingType.userModel,
      url: apiEndpoints.apiUpdateUser(userId),
      requestBody: MyUtils.encodeJson(updateMap),
      isAuthenticatedApiCall: true,
    );

    DataResponseModel<UserListModel> apiResponseModel =
    await apiController.callApi<UserListModel>(
      apiCallModel: apiCallModel,
    );
    return apiResponseModel;
  }
}
