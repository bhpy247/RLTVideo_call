class ApiUrlConfigurationProvider {
  //region Main Site Url
  String _mainSiteUrl = "";

  String getMainSiteUrl() => _mainSiteUrl;

  void setMainSiteUrl(String url) => _mainSiteUrl = url;
  //endregion

  //region Main Client Url Type
  int _mainClientUrlType = -1;

  int getMainClientUrlType() => _mainClientUrlType;

  void setMainClientUrlType(int type) => _mainClientUrlType = type;

  //endregion

  //region Current Base Api Url
  String _currentBaseApiUrl = "";

  String getCurrentBaseApiUrl() => _currentBaseApiUrl;

  void setCurrentBaseApiUrl(String url) => _currentBaseApiUrl = url;

  //endregion

  //region Current Site Url
  String _currentSiteUrl = "";

  String getCurrentSiteUrl() => _currentSiteUrl;

  void setCurrentSiteUrl(String url) => _currentSiteUrl = url;

  //endregion

  //region Current Auth Url
  String _currentAuthUrl = "";

  String getCurrentAuthUrl() => _currentAuthUrl;

  void setCurrentAuthUrl(String token) => _currentAuthUrl = token;

  //endregion

  //region Current Site Learner Url
  String _currentSiteLearnerUrl = "";

  String getCurrentSiteLearnerUrl() => _currentSiteLearnerUrl;

  void setCurrentSiteLearnerUrl(String url) => _currentSiteLearnerUrl = url;

  //endregion

  //region Current Site LMS Url
  String _currentSiteLMSUrl = "";

  String getCurrentSiteLMSUrl() => _currentSiteLMSUrl;

  void setCurrentSiteLMSUrl(String url) => _currentSiteLMSUrl = url;

  //endregion

  //region Current Client Url Type
  int _currentClientUrlType = -1;

  int getCurrentClientUrlType() => _currentClientUrlType;

  void setCurrentClientUrlType(int type) => _currentClientUrlType = type;

  //endregion

  //region UserId
  int _currentUserId = -1;

  int getCurrentUserId() => _currentUserId;

  void setCurrentUserId(int id) => _currentUserId = id;

  //endregion

  //region SiteId
  int _currentSiteId = -1;

  int getCurrentSiteId() => _currentSiteId;

  void setCurrentSiteId(int id) => _currentSiteId = id;
  //endregion

  //region Locale
  String _locale = "en-us";

  String getLocale() => _locale;

  void setLocale(String locale) => _locale = locale;

  //endregion

  //region Auth Token
  String _authToken = "";

  String getAuthToken() => _authToken;

  void setAuthToken(String token) => _authToken = token;

  //endregion

  //region SubSite
  bool _isSubSiteEntered = false;

  bool getIsSubSiteEntered() => _isSubSiteEntered;

  void setIsSubSiteEntered(bool val) => _isSubSiteEntered = val;
//endregion
}