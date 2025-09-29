
import '../../utils/parsing_helper.dart';

class LoginResponseModel {
  User? user;
  String token = "";

  LoginResponseModel({this.user, this.token = ""});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    token = ParsingHelper.parseStringMethod(json['token']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    return data;
  }
}

class User {
  String name = "";
  String id = "";

  User({this.name = "", this.id = ""});

  User.fromJson(Map<String, dynamic> json) {
    name = ParsingHelper.parseStringMethod(json["name"]);
    id = ParsingHelper.parseStringMethod(json["id"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    return data;
  }
}
