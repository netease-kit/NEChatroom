// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

const _tag = '_HttpExecutor';

class _HttpExecutor with _AloggerMixin {
  static _HttpExecutor? _instance;

  factory _HttpExecutor() {
    return _instance ??= _HttpExecutor._internal();
  }

  late http.Dio dio;
  final ServersConfig _serversConfig = ServersConfig();

  _HttpExecutor._internal() {
    var options = http.BaseOptions(
        baseUrl: _serversConfig.baseUrl,
        connectTimeout: _serversConfig.connectTimeout,
        receiveTimeout: _serversConfig.receiveTimeout);

    dio = http.Dio(options);
  }

  Future<http.Response?> _execute(
      String path, Map<String, dynamic>? headers, data) async {
    http.Response? response;
    Map<String, dynamic>? _baseHeaders = {
      'deviceId': _serversConfig.deviceId,
      'clientType': 'aos',
      'appkey': _serversConfig.appKey,
      'user': _serversConfig.userUuid,
      'token': _serversConfig.token,
      'Accept-Language': _getLanguage(),
    };
    try {
      var options = http.Options();
      options.headers = mergeHeaders(_baseHeaders, headers);
      commonLogger.i('execute path:$path header:${options.headers} data:$data');
      if (path.startsWith('http')) {
        response =
            await dio.postUri(Uri.parse(path), data: data, options: options);
      } else {
        response = await dio.post(path, data: data, options: options);
      }
    } on http.DioError catch (e) {
      commonLogger.e('execute error:$e');
    }
    return response;
  }

  Future<NEResult<dynamic>> _post<T>(String path, data) async {
    var response = await _execute(path, null, data);
    if (response == null) {
      return const NEResult(code: -1, msg: 'Network Error');
    } else {
      if (response.statusCode != 200) {
        return NEResult(code: response.statusCode ?? -1, msg: 'Network Error');
      }
      if (response.data == null || response.data is! Map) {
        return const NEResult(code: -1, msg: 'No Data');
      }

      try {
        var map = response.data as Map;
        var code = map['code'] as int;
        var requestId = map['requestId'] as String;
        var msg = map['msg'] as String?;
        var data = map['data'];
        commonLogger.i('execute requestId:$requestId response:$map');
        if (code != 200) {
          return NEResult(
              code: code, msg: msg ?? 'Empty message in response body!');
        }
        if (data == null) {
          return const NEResult(code: 0, msg: 'No sub data');
        }
        if (data is Map<String, dynamic>) {
          return NEResult(code: 0, data: data);
        } else {
          return NEResult(code: 0, msg: data);
        }
      } catch (e, s) {
        return const NEResult(code: -1, msg: 'Server Error');
      }
    }
  }

  Future<http.Response?> _getExecute(
      String path, Map<String, dynamic>? headers) async {
    http.Response? response;
    Map<String, dynamic>? _baseHeaders = {
      'deviceId': _serversConfig.deviceId,
      'clientType': 'aos',
      'appkey': _serversConfig.appKey,
      'user': _serversConfig.userUuid,
      'token': _serversConfig.token,
      'Accept-Language': _getLanguage(),
    };
    try {
      var options = http.Options();
      options.headers = mergeHeaders(_baseHeaders, headers);
      commonLogger.i('execute path:$path header:${options.headers} ');
      if (path.startsWith('http')) {
        response = await dio.getUri(Uri.parse(path));
      } else {
        response = await dio.get(path, options: options);
      }
    } on http.DioError catch (e) {
      commonLogger.e('execute error:$e');
    }
    return response;
  }

  Future<NEResult<dynamic>> _get<T>(String path) async {
    var response = await _getExecute(path, null);
    if (response == null) {
      return const NEResult(code: -1, msg: 'Network Error');
    } else {
      if (response.statusCode != 200) {
        return NEResult(code: response.statusCode ?? -1, msg: 'Network Error');
      }
      if (response.data == null || response.data is! Map) {
        return const NEResult(code: -1, msg: 'No Data');
      }

      try {
        var map = response.data as Map;
        var code = map['code'] as int;
        var requestId = map['requestId'] as String;
        var msg = map['msg'] as String?;
        var data = map['data'];
        commonLogger.i('execute requestId:$requestId response:$map');
        if (code != 200) {
          return NEResult(
              code: code, msg: msg ?? 'Empty message in response body!');
        }
        if (data == null) {
          return const NEResult(code: 0, msg: 'No sub data');
        }
        if (data is Map<String, dynamic>) {
          return NEResult(code: 0, data: data);
        } else {
          return NEResult(code: 0, msg: data);
        }
      } catch (e, s) {
        return const NEResult(code: -1, msg: 'Server Error');
      }
    }
  }

  Map<String, dynamic>? mergeHeaders(
      Map<String, dynamic>? lhs, Map<String, dynamic>? rhs) {
    if (lhs != null || rhs != null) {
      return {
        if (lhs != null) ...(lhs..removeWhere((key, value) => value == null)),
        if (rhs != null) ...(rhs..removeWhere((key, value) => value == null)),
      };
    }
    return null;
  }

  String _getLanguage() {
    String language = "en";
    if (Platform.localeName == "zh_CN" || Platform.localeName == "zh_Hans_CN") {
      language = "zh";
    }
    return language;
  }
}
