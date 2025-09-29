import 'package:videocall/api/api_call_model.dart';
import 'package:videocall/api/api_controller.dart';
import 'package:videocall/api/api_endpoints.dart';
import 'package:videocall/api/rest_client.dart';
import 'package:videocall/models/common/data_response_model.dart';
import 'package:videocall/models/common/model_data_parser.dart';
import 'package:videocall/utils/my_print.dart';
import '../../models/user_model/user_list_model.dart';

class UserListRepository {
  final ApiController apiController;

  const UserListRepository({required this.apiController});

  // Fetch user list from ReqRes API
  Future<DataResponseModel<UserListResponseModel>> getUserList({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      // Using ReqRes API as a fake REST API
      const String baseUrl = 'https://reqres.in/api';
      final String url = '$baseUrl/users?page=$page&per_page=$perPage';

      MyPrint.printOnConsole("Fetching users from: $url");

      ApiCallModel apiCallModel = await apiController.getApiCallModelFromData<String>(
        restCallType: RestCallType.simpleGetCall,
        parsingType: ModelDataParsingType.userListModel,
        url: url,
        isAuthenticatedApiCall: false,
      );

      DataResponseModel<UserListResponseModel> apiResponseModel =
      await apiController.callApi<UserListResponseModel>(
        apiCallModel: apiCallModel,
      );

      return apiResponseModel;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in UserListRepository.getUserList: $e");
      MyPrint.printOnConsole(s);

      return DataResponseModel<UserListResponseModel>(
        statusCode: 500,
        // message: "Failed to fetch users: $e",
      );
    }
  }

  // Get single user by ID
  Future<DataResponseModel<UserListModel>> getUserById(int userId) async {
    try {
      const String baseUrl = 'https://reqres.in/api';
      final String url = '$baseUrl/users/$userId';

      MyPrint.printOnConsole("Fetching user from: $url");

      ApiCallModel apiCallModel = await apiController.getApiCallModelFromData<String>(
        restCallType: RestCallType.simpleGetCall,
        parsingType: ModelDataParsingType.singleUserModel,
        url: url,
        isAuthenticatedApiCall: false,
      );

      DataResponseModel<UserListModel> apiResponseModel =
      await apiController.callApi<UserListModel>(
        apiCallModel: apiCallModel,
      );

      return apiResponseModel;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in UserListRepository.getUserById: $e");
      MyPrint.printOnConsole(s);

      return DataResponseModel<UserListModel>(
        statusCode: 500,
        // message: "Failed to fetch user: $e",
      );
    }
  }
}