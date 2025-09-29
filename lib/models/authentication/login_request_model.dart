
import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class EmailLoginRequestModel {
  String email = "", password = "";

  EmailLoginRequestModel({
    this.email = "",
    this.password = "",
  });

  EmailLoginRequestModel.fromJson(Map<String, dynamic> json) {
    email = ParsingHelper.parseStringMethod(json["email"]);
    password = ParsingHelper.parseStringMethod(json["password"]);
  }

  Map<String, String> toJson() {
    return {
      "email": email.toLowerCase(),
      "password": password,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toJson());
  }
}

class RegistrationRequestModel {
  String email = "", password = "", name = "";

  RegistrationRequestModel({
    this.email = "",
    this.password = "",
    this.name = "",
  });

  RegistrationRequestModel.fromJson(Map<String, dynamic> json) {
    email = ParsingHelper.parseStringMethod(json["email"]);
    password = ParsingHelper.parseStringMethod(json["password"]);
    name = ParsingHelper.parseStringMethod(json["name"]);
  }

  Map<String, String> toJson() {
    return {
      "email": email,
      "password": password,
      "name": name,
      "coins":"25",
      "energy":"5"
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toJson());
  }
}