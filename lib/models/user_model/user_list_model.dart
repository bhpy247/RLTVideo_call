import 'package:hive/hive.dart';

part 'user_list_model.g.dart';

@HiveType(typeId: 0)
class UserListModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String firstName;

  @HiveField(3)
  final String lastName;

  @HiveField(4)
  final String avatar;

  UserListModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  String get fullName => '$firstName $lastName';

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    return UserListModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }

  @override
  String toString() {
    return 'UserListModel(id: $id, email: $email, name: $fullName)';
  }
}

class UserListResponseModel {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<UserListModel> data;

  UserListResponseModel({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory UserListResponseModel.fromJson(Map<String, dynamic> json) {
    return UserListResponseModel(
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 6,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => UserListModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}