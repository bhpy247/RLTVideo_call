import 'dart:developer' as developer;

import 'package:videocall/utils/shared_pref_manager.dart';

import 'my_utils.dart';

String _logData = "";
bool? _isRecordLog;

class MyPrint {

  static void printOnConsole(Object s, {String? tag}) {
    String logMessage = "${(tag?.isNotEmpty ?? false) ? "$tag " : ""}${s.toString()}";
    appendLogData(logMessage: logMessage);
    print(logMessage);
  }

  static void logOnConsole(Object s, {String? tag}) {
    String logMessage = "${(tag?.isNotEmpty ?? false) ? "$tag " : ""}${s.toString()}";
    appendLogData(logMessage: logMessage);
    developer.log(logMessage);
  }

  static void appendLogData({required String logMessage}) {
    if (_isRecordLog ?? false) _logData += "\n$logMessage";
  }

  static bool? get isRecordLog => _isRecordLog;

  static void setIsRecordLog(bool isRecord) => _isRecordLog = isRecord;

  static String getLog() {
    String log = _logData;
    developer.log("log length:${log.length}");

    _logData = "";

    return log;
  }

  static Future<void> initializeRecordVlog() async {
    String tag = MyUtils.getNewId();
    print("$tag:MyPrint.initializeRecordVlog() called");

    String key = "_isRecordLog";
    bool? value = await SharedPrefManager().getBool(key);
    print("$tag:isRecordLog from SharedPreference:$value");

    if (value == null) {
      value = false;
      SharedPrefManager().setBool(key, value);
    }
    print("$tag:final isRecordLog:$value");

    _isRecordLog = value;
  }
}
