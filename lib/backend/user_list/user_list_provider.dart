import 'package:videocall/backend/common/common_provider.dart';
import '../../models/user_model/user_list_model.dart';

class UserListProvider extends CommonProvider {
  UserListProvider() {
    userList = CommonProviderPrimitiveParameter<List<UserListModel>>(
      value: [],
      notify: notify,
    );

    isLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    errorMessage = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );

    currentPage = CommonProviderPrimitiveParameter<int>(
      value: 1,
      notify: notify,
    );

    totalPages = CommonProviderPrimitiveParameter<int>(
      value: 1,
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<List<UserListModel>> userList;
  late CommonProviderPrimitiveParameter<bool> isLoading;
  late CommonProviderPrimitiveParameter<String> errorMessage;
  late CommonProviderPrimitiveParameter<int> currentPage;
  late CommonProviderPrimitiveParameter<int> totalPages;

  void resetData({bool isNotify = true}) {
    userList.set(value: [], isNotify: false);
    isLoading.set(value: false, isNotify: false);
    errorMessage.set(value: "", isNotify: false);
    currentPage.set(value: 1, isNotify: false);
    totalPages.set(value: 1, isNotify: isNotify);
  }
}