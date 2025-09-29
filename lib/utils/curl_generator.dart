import 'package:http/http.dart';

import 'my_print.dart';
import 'my_utils.dart';
import 'parsing_helper.dart';

enum Platform { WIN, POSIX }

class CurlGenerator {
  static final _r1 = RegExp(r'"');
  static final _r2 = RegExp(r'%');
  static final _r3 = RegExp(r"\\");
  static final _r4 = RegExp(r"[\r\n]+");
  static final _r5 = RegExp(r"[^\x20-\x7E]|'");
  static final _r7 = RegExp(r"'");
  static final _r8 = RegExp(r"\n");
  static final _r9 = RegExp(r"\r");
  static final _r10 = RegExp(r"[[{}\]]");
  static const _urlencoded = "application/x-www-form-urlencoded";

  static String toCurl(Request req, {Platform platform = Platform.POSIX}) {
    try {
      List<String> command = ["curl", "--location", "--request"];
      List<String> ignoredHeaders = ["host", "method", "path", "scheme", "version"];
      final escapeString = platform == Platform.WIN? _escapeStringWindows: _escapeStringPosix;
      String requestMethod = req.method;
      List<String> data = <String>[];
      final Map<String, String> requestHeaders = req.headers;
      final String requestBody = req.body;
      final String contentType = requestHeaders["content-type"] ?? "";

      command.add(requestMethod);
      command.add(escapeString("${req.url.origin}${req.url.path}?${req.url.query}"));
      // command.add(escapeString("${req.url.origin}${req.url.path}").replaceAllMapped(_r10, (match) => "\\${match.group(0)}"));
      if (contentType.indexOf(_urlencoded) == 0) {
        ignoredHeaders.add("content-length");
        // data.add("--data");
        // data.add(escapeString(req.bodyFields.keys.map((key) => "${Uri.encodeComponent(key)}=${Uri.encodeComponent(req.bodyFields[key] ?? "")}").join("&")));
        Map<String, String> body = ParsingHelper.parseMapMethod<dynamic, dynamic, String, String>(MyUtils.decodeJson(requestBody));
        body.forEach((key, value) {
          MyPrint.printOnConsole("In bodyFields:$key=$value");
          data.add("--data-urlencode '$key=$value'");
        });
      }
      else if (requestBody.isNotEmpty) {
        ignoredHeaders.add("content-length");
        data.add("--data-raw");
        data.add(escapeString(requestBody));
      }

      // if (req.method != requestMethod) {
      //   command..add("-X")..add(req.method);
      // }
      Map<String, String>.fromIterable(
        requestHeaders.keys.where((k) => !ignoredHeaders.contains(k)),
        value: (k) => requestHeaders[k] ?? "",
      ).forEach((k, v) {
        command..add("--header")..add(escapeString("$k: $v"));
      });
      return (command..addAll(data)/*..add("--compressed")..add("--insecure")*/).join(" ");
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in CurlGenerator.toCurl():$e");
      MyPrint.printOnConsole(s);
      return "";
    }
  }

  static String toCurlFromRawRequest({required String method, required String url, Map<String, String> headers = const <String, String>{}, String body = ""}) {
    try {
      Request request = Request(method, Uri.parse(url),);
      request.headers.addAll(headers);
      request.body = body;

      return toCurl(request);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Generating CurlFromRawRequest:$e");
      MyPrint.printOnConsole(s);
      return "";
    }
  }

  static String _escapeStringWindows(String str) => "\"${str.replaceAll(_r1, "\"\"")
      .replaceAll(_r2, "\"%\"")
      .replaceAll(_r3, "\\\\")
      .replaceAllMapped(_r4, (match) => "\"^${match.group(0)}\"")}\"";

  static String _escapeStringPosix(String str) {
    if (_r5.hasMatch(str)) {
      // Use ANSI-C quoting syntax.
      return "\$\'${str.replaceAll(_r3, "\\\\")
        .replaceAll(_r7, "\\\'")
        .replaceAll(_r8, "\\n")
        .replaceAll(_r9, "\\r")
        .replaceAllMapped(_r5, (Match match) {
          String x = match.group(0) ?? "";
          assert(x.length == 1);
          final code = x.codeUnitAt(0);
          if (code < 256) {
            // Add leading zero when needed to not care about the next character.
            return code < 16 ? "\\x0${code.toRadixString(16)}" : "\\x${code.toRadixString(16)}";
          }
          final c = code.toRadixString(16);
          return "\\u${("0000$c").substring(c.length, c.length + 4)}";
        })}'";
    }
    else {
      // Use single quote syntax.
      return "'$str'";
    }
  }
}