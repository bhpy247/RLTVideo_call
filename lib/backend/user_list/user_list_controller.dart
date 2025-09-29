import 'package:hive_flutter/adapters.dart';
import 'package:videocall/backend/user_list/user_list_provider.dart';
import 'package:videocall/backend/user_list/user_list_repository.dart';
import 'package:videocall/utils/my_print.dart';
import 'package:videocall/api/api_controller.dart';

import '../../models/user_model/user_list_model.dart';

class UserListController {
  late UserListProvider _userListProvider;
  late UserListRepository _userListRepository;
  late Box<UserListModel> _userCacheBox;

  UserListController({
    UserListProvider? userListProvider,
    UserListRepository? repository,
  }) {
    _userListProvider = userListProvider ?? UserListProvider();
    _userListRepository = repository ?? UserListRepository(apiController: ApiController());
    _initializeCache();
  }

  UserListProvider get userListProvider => _userListProvider;
  UserListRepository get userListRepository => _userListRepository;

  // Initialize Hive cache
  Future<void> _initializeCache() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserListModelAdapter());
      }
      _userCacheBox = await Hive.openBox<UserListModel>('userListCache');
      MyPrint.printOnConsole("User cache initialized");
    } catch (e, s) {
      MyPrint.printOnConsole("Error initializing cache: $e");
      MyPrint.printOnConsole(s);
    }
  }

  // Fetch users from API
  Future<bool> fetchUsers({bool forceRefresh = false}) async {
    try {
      _userListProvider.isLoading.set(value: true, isNotify: true);

      // Try to fetch from API
      final response = await _userListRepository.getUserList();

      if (response.data != null && response.statusCode == 200) {
        final users = response.data!.data;

        // Update provider
        _userListProvider.userList.set(value: users, isNotify: true);

        // Cache the users
        await _cacheUsers(users);

        _userListProvider.isLoading.set(value: false, isNotify: true);
        _userListProvider.errorMessage.set(value: "", isNotify: true);

        MyPrint.printOnConsole("Successfully fetched ${users.length} users");
        return true;
      } else {
        // If API fails, try to load from cache
        return await loadUsersFromCache();
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error fetching users: $e");
      MyPrint.printOnConsole(s);

      // Load from cache on error
      return await loadUsersFromCache();
    }
  }

  // Cache users locally
  Future<void> _cacheUsers(List<UserListModel> users) async {
    try {
      await _userCacheBox.clear();
      for (var user in users) {
        await _userCacheBox.put(user.id.toString(), user);
      }
      MyPrint.printOnConsole("Cached ${users.length} users");
    } catch (e, s) {
      MyPrint.printOnConsole("Error caching users: $e");
      MyPrint.printOnConsole(s);
    }
  }

  // Load users from cache (offline mode)
  Future<bool> loadUsersFromCache() async {
    try {
      if (_userCacheBox.isNotEmpty) {
        final cachedUsers = _userCacheBox.values.toList();
        _userListProvider.userList.set(value: cachedUsers, isNotify: true);
        _userListProvider.isLoading.set(value: false, isNotify: true);
        _userListProvider.errorMessage.set(
          value: "Showing cached data (offline mode)",
          isNotify: true,
        );

        MyPrint.printOnConsole("Loaded ${cachedUsers.length} users from cache");
        return true;
      } else {
        _userListProvider.isLoading.set(value: false, isNotify: true);
        _userListProvider.errorMessage.set(
          value: "No cached data available",
          isNotify: true,
        );
        return false;
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error loading from cache: $e");
      MyPrint.printOnConsole(s);
      _userListProvider.isLoading.set(value: false, isNotify: true);
      _userListProvider.errorMessage.set(
        value: "Failed to load data",
        isNotify: true,
      );
      return false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _userCacheBox.clear();
      MyPrint.printOnConsole("Cache cleared");
    } catch (e, s) {
      MyPrint.printOnConsole("Error clearing cache: $e");
      MyPrint.printOnConsole(s);
    }
  }

  // Get user by ID
  UserListModel? getUserById(int userId) {
    try {
      return _userListProvider.userList.get().firstWhere(
            (user) => user.id == userId,
      );
    } catch (e) {
      MyPrint.printOnConsole("User with ID $userId not found");
      return null;
    }
  }

  // Refresh users
  Future<bool> refreshUsers() async {
    return await fetchUsers(forceRefresh: true);
  }
}