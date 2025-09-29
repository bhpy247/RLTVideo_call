import 'dart:io';

import 'package:http/http.dart';
import 'package:videocall/utils/extensions.dart';

import '../utils/app_string.dart';
import '../utils/curl_generator.dart';
import '../utils/date_representation.dart';
import '../utils/my_print.dart';
import '../utils/my_utils.dart';
import '../utils/parsing_helper.dart';
import 'api_call_model.dart';

typedef RestCallTypeDef = Future<Response?> Function({required ApiCallModel apiCallModel});

enum RestCallType {
  simpleGetCall,
  simplePostCall,
  simplePatchCall,
  multipartRequestCall,
  saveGenericFilesCall,
  xxxUrlEncodedFormDataRequestCall,
}

class RestClient {
  static Map<RestCallType, RestCallTypeDef> callsMap = <RestCallType, RestCallTypeDef>{
    RestCallType.simpleGetCall: getCall,
    RestCallType.simplePostCall: postCall,
    RestCallType.simplePatchCall: patchCall,
    // RestCallType.multipartRequestCall: multipartRequestCall,
    // RestCallType.saveGenericFilesCall: saveGenericFilesCall,
    // RestCallType.xxxUrlEncodedFormDataRequestCall: xxxUrlEncodedFormDataRequestCall,
  };

  static Future<Response?> callApi({required ApiCallModel apiCallModel}) async {
    RestCallTypeDef? type = callsMap[apiCallModel.restCallType];

    if(type != null) {
      return type(apiCallModel: apiCallModel);
    }
    else {
      return null;
    }
  }

  static Future<Response?> getCall({required ApiCallModel apiCallModel}) async {
    Map<String, String> headers = _getRequiredHeadersFromApiCallModel(apiCallModel: apiCallModel);

    String newId = MyUtils.getNewId(isFromUUuid: true);

    try {
      String url = _getFinalApiUrl(url: apiCallModel.url, queryParameters: apiCallModel.queryParameters);

      MyPrint.printOnConsole("getCall called", tag: newId);
      MyPrint.printOnConsole("Url:'$url'", tag: newId);
      MyPrint.printOnConsole("Headers:$headers", tag: newId);

      MyPrint.logOnConsole("Curl Request:${CurlGenerator.toCurlFromRawRequest(
        method: "GET",
        url: url,
        headers: headers,
      )}", tag: newId);


      DateTime startTime = DateTime.now();
      // MyPrint.printOnConsole("Api startTime:${DatePresentation.fullDateTimeFormat(startTime)} Seconds", tag: newId);

      Response response = await get(Uri.parse(url), headers: headers);

      DateTime endTime = DateTime.now();
      // MyPrint.printOnConsole("Api endTime:${DatePresentation.fullDateTimeFormat(endTime)}", tag: newId);

      MyPrint.printOnConsole("Response Time:${endTime.difference(startTime).inMilliseconds / 1000} Seconds", tag: newId);
      MyPrint.printOnConsole("Response Status:${response.statusCode}", tag: newId);
      MyPrint.logOnConsole("Response Body:${response.body}", tag: newId);

      // MyLogger.i(response.body);

      return response;
    }
    catch (e, s) {
      MyPrint.printOnConsole("Error in Getting Response in RestClient.getCall():$e", tag: newId);
      MyPrint.printOnConsole(s, tag: newId);
      return null;
    }
  }

  static Future<Response?> postCall({required ApiCallModel apiCallModel}) async {
    Map<String, String> headers = _getRequiredHeadersFromApiCallModel(apiCallModel: apiCallModel);

    String newId = MyUtils.getNewId(isFromUUuid: true);

    try {
      String url = _getFinalApiUrl(url: apiCallModel.url, queryParameters: apiCallModel.queryParameters);

      MyPrint.printOnConsole("postCall called", tag: newId);
      MyPrint.printOnConsole("Url:'$url'", tag: newId);
      MyPrint.printOnConsole("Headers:$headers", tag: newId);
      MyPrint.printOnConsole("RequestBody:${apiCallModel.requestBody}", tag: newId);

      MyPrint.logOnConsole("Curl Request:${CurlGenerator.toCurlFromRawRequest(
        method: "POST",
        url: url,
        headers: headers,
        body: ParsingHelper.parseStringMethod(apiCallModel.requestBody),
      )}", tag: newId);


      DateTime startTime = DateTime.now();
      // MyPrint.printOnConsole("Api startTime:${DatePresentation.fullDateTimeFormat(startTime)} Seconds", tag: newId);

      Response response = await post(Uri.parse(url), headers: headers, body: apiCallModel.requestBody);

      DateTime endTime = DateTime.now();
      // MyPrint.printOnConsole("Api endTime:${DatePresentation.fullDateTimeFormat(endTime)}", tag: newId);

      MyPrint.printOnConsole("Response Time:${endTime.difference(startTime).inMilliseconds / 1000} Seconds", tag: newId);
      MyPrint.printOnConsole("Response Status:${response.statusCode}", tag: newId);
      MyPrint.logOnConsole("Response Body:${response.body}", tag: newId);

      // MyLogger.i(response.body);

      return response;
    }
    catch (e, s) {
      MyPrint.printOnConsole("Error in Getting Response in RestClient.postCall():$e", tag: newId);
      MyPrint.printOnConsole(s, tag: newId);
      return null;
    }
  }

  static Future<Response?> patchCall({required ApiCallModel apiCallModel}) async {
    Map<String, String> headers = _getRequiredHeadersFromApiCallModel(apiCallModel: apiCallModel);

    String newId = MyUtils.getNewId(isFromUUuid: true);

    try {
      String url = _getFinalApiUrl(url: apiCallModel.url, queryParameters: apiCallModel.queryParameters);

      MyPrint.printOnConsole("Patch called", tag: newId);
      MyPrint.printOnConsole("Url:'$url'", tag: newId);
      MyPrint.printOnConsole("Headers:$headers", tag: newId);
      MyPrint.printOnConsole("RequestBody:${apiCallModel.requestBody}", tag: newId);

      MyPrint.logOnConsole("Curl Request:${CurlGenerator.toCurlFromRawRequest(
        method: "Patch",
        url: url,
        headers: headers,
        body: ParsingHelper.parseStringMethod(apiCallModel.requestBody),
      )}", tag: newId);


      DateTime startTime = DateTime.now();
      // MyPrint.printOnConsole("Api startTime:${DatePresentation.fullDateTimeFormat(startTime)} Seconds", tag: newId);

      Response response = await patch(Uri.parse(url), headers: headers, body: apiCallModel.requestBody);

      DateTime endTime = DateTime.now();
      // MyPrint.printOnConsole("Api endTime:${DatePresentation.fullDateTimeFormat(endTime)}", tag: newId);

      MyPrint.printOnConsole("Response Time:${endTime.difference(startTime).inMilliseconds / 1000} Seconds", tag: newId);
      MyPrint.printOnConsole("Response Status:${response.statusCode}", tag: newId);
      MyPrint.logOnConsole("Response Body:${response.body}", tag: newId);

      // MyLogger.i(response.body);

      return response;
    }
    catch (e, s) {
      MyPrint.printOnConsole("Error in Getting Response in RestClient.Patch():$e", tag: newId);
      MyPrint.printOnConsole(s, tag: newId);
      return null;
    }
  }




  static String _getFinalApiUrl({required String url, Map<String, String>? queryParameters}) {
    return url + (queryParameters.checkNotEmpty ? getQueryParametersStringFromData(queryParameters: queryParameters!) : "");
  }

  static String getQueryParametersStringFromData({required Map<String, String> queryParameters}) {
    MyPrint.printOnConsole("RestClient.getQueryParametersStringFromData() called for queryParameters:'${MyUtils.encodeJson(queryParameters)}'");

    String queryParametersString = "";

    if(queryParameters.isNotEmpty) {
      queryParametersString += "?";

      queryParameters.forEach((String key, String value) {
        queryParametersString += "$key=$value&";
      });

      queryParametersString = queryParametersString.substring(0, queryParametersString.length - 1);
    }

    MyPrint.printOnConsole("Final queryParametersString:$queryParametersString");
    return queryParametersString;
  }

  static Map<String, String> _getRequiredHeadersFromApiCallModel({required ApiCallModel apiCallModel, String? contentType}) {
    Map<String, String> map = <String, String>{
      HttpHeaders.contentTypeHeader: contentType ?? ContentType.json.value,
        'x-api-key': 'reqres-free-v1',
      // "ClientURL": apiCallModel.siteUrl,
      // AppStrings.allowFromExternalHostKey: 'allow',
      // "SiteID": apiCallModel.siteId.toString(),
      // "Locale": apiCallModel.locale,
      // "Accept": "*/*",
    };

    if(apiCallModel.isAuthenticatedApiCall) {
      map.addAll(<String, String>{
        "Authorization": 'Bearer ${apiCallModel.token}',
        // "Accept": "*/*",
      });
    }

    return map;
  }
}