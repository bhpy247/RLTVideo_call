class ApiEndpoints {
  final String siteUrl, authUrl, apiUrl ;

  const ApiEndpoints({
    required this.siteUrl,
    required this.authUrl,
    // this.apiUrl = "http://localhost:55557/api/v1",
    this.apiUrl = "https://quiz-backend-1-yjm4.onrender.com/api/v1",
  });

  String getAuthUrl() {
    return authUrl;
  }

  String getSiteUrl() {
    return siteUrl;
  }

  String getBaseApiUrl() {
    // return "http://192.168.29.164:55557/api/v1";
    return "https://quiz-backend-1-yjm4.onrender.com/api/v1";
  }



  //region Authentication Api
  String apiPostLoginDetails() {
    return "${getBaseApiUrl()}/auth/login";
  }

  String apiRegisterUser() {
    return "${getBaseApiUrl()}/auth/register";
  }
  // String apiSignUpUser({
  //   required String locale,
  // }) =>
  //     '${getBaseApiUrl()}MobileLMS/MobileCreateSignUp?Locale=$locale&SiteURL=$siteUrl';

  //endregion
  String apiGetUser(String userId) {
    return "${getBaseApiUrl()}/users/$userId";
  }

  String apiUpdateUser(String userId) {
    return "${getBaseApiUrl()}/users/$userId";
  }

  String qpiGetQuizQuestion(String levelId) {
    return "${getBaseApiUrl()}/question/getQuestion/$levelId";
  }
  //region GetUser

  //endregion

  //region Home Menu Api

}
