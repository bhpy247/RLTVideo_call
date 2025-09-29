import 'package:flutter/foundation.dart';
import 'package:videocall/api/rest_client.dart';

import '../models/common/model_data_parser.dart';

@immutable
class ApiCallModel<RequestBodyType> {
  final RestCallType restCallType;
  final ModelDataParsingType parsingType;
  final String url, siteUrl, locale, token;
  final int userId, siteId;
  final Map<String, String>? queryParameters;
  final RequestBodyType? requestBody;
  // final List<InstancyMultipartFileUploadModel>? files;
  final Map<String, String>? fields;
  final bool isAuthenticatedApiCall, isGetDataFromHive, isStoreDataInHive;
  // final Box? hiveBox;
  bool isIsolateCall;

  ApiCallModel({
    required this.restCallType,
    required this.parsingType,
    required this.url,
    required this.siteUrl,
    this.locale = "",
    this.token = "",
    this.userId = -1,
    this.siteId = 374,
    this.queryParameters,
    this.requestBody,
    // this.files,
    this.fields,
    this.isAuthenticatedApiCall = true,
    this.isGetDataFromHive = false,
    this.isStoreDataInHive = false,
    this.isIsolateCall = true,
    // this.hiveBox,
  });


}