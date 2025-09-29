import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import 'my_http_overrides.dart';
import 'my_print.dart';
import 'my_toast.dart';

class MyUtils {
  static Future<void> copyToClipboard(BuildContext? context, String string) async {
    if (string.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: string));
      if (context != null) {
        MyToast.showSuccess(context: context, msg: "Copied");
      }
    }
  }

  static String getNewId({bool isFromUUuid = true}) {
    if (isFromUUuid) {
      return const Uuid().v1().replaceAll("-", "");
    } else {
      return "123";
    }
  }

  static String encodeJson(Object? object) {
    try {
      return jsonEncode(object);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in MyUtils.encodeJson():$e");
      MyPrint.printOnConsole(s);
      return "";
    }
  }

  static dynamic decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in MyUtils.decodeJson():$e");
      MyPrint.printOnConsole(s);
      return null;
    }
  }

  static Future<String> getDocumentsDirectory() async {
    if (kIsWeb) {
      return "";
    }
    final directory = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
    return directory?.path ?? "";
  }

  static void hideShowKeyboard({bool isHide = true}) {
    SystemChannels.textInput.invokeMethod(isHide ? 'TextInput.hide' : 'TextInput.show');
  }

  static void initializeHttpOverrides() {
    if (!kIsWeb) {
      HttpOverrides.global = MyHttpOverrides();
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    }
  }

  static String getSecureUrl(String url) {
    String scheme = Uri.base.scheme;
    // MyPrint.printOnConsole("scheme:$scheme");

    String current = "", target = "";
    if (scheme == "http") {
      current = "https:";
      target = "http:";
    } else if (scheme == "https") {
      current = "http:";
      target = "https:";
    }
    // MyPrint.printOnConsole("current:$current");

    if (current.isNotEmpty && target.isNotEmpty && url.startsWith(current)) {
      url = url.replaceFirst(current, target);
    }
    return url;
  }

  static String getHostNameFromSiteUrl(String url) {
    if (url.startsWith("http://") || url.startsWith("https://")) {
      Uri uri = Uri.parse(url);
      return uri.host;
    }

    return "";
  }

  static Future<List<PlatformFile>> pickFiles({required FileType pickingType, bool multiPick = false, String extensions = "", bool getBytes = false}) async {
    String extension = "";
    if (extensions.isNotEmpty) {
      extension = extensions;
    } else if (pickingType == FileType.custom) {
      extension = 'xlsx,pptx,docx,txt,doc,pdf';
    }

    List<PlatformFile> paths = [];
    try {
      FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
        type: pickingType,
        allowMultiple: multiPick,
        allowedExtensions: (extension.isNotEmpty) ? extension.replaceAll(' ', '').split(',') : null,
        withData: getBytes,
      );
      paths = filePickerResult?.files ?? [];
    } on PlatformException catch (e, s) {
      MyPrint.printOnConsole('Error PlatformException in MyUtils.pickFiles():$e');
      MyPrint.printOnConsole(s);
      MyPrint.printOnConsole("Unsupported operation$e");
    } catch (e, s) {
      MyPrint.printOnConsole('Error in MyUtils.pickFiles():$e');
      MyPrint.printOnConsole(s);
    }

    return paths;
  }

  static Future<bool> launchUrl({required String url, LaunchMode launchMode = LaunchMode.externalApplication}) async {
    String tag = getNewId();
    MyPrint.printOnConsole("MyUtils.launchUrl() called", tag: tag);
    bool isCanLaunch = false, isLaunched = false;

    try {
      isCanLaunch = await canLaunchUrlString(url);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Checking canLaunchUrlString in MyUtils.launchUrl():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    if (isCanLaunch) {
      try {
        isLaunched = await launchUrlString(
          url,
          mode: launchMode,
        );
      } catch (e, s) {
        MyPrint.printOnConsole("Error in Checking canLaunchUrlString in MyUtils.launchUrl():$e", tag: tag);
        MyPrint.printOnConsole(s, tag: tag);
      }
    }

    return isLaunched;
  }


  static List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  static double roundTo(double value, double precision) => (value * precision).round() / precision;

}
