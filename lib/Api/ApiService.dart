import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:cryptovoteui/Models/Wallet.dart';
import 'package:http/http.dart' as http;

class ApiService
{
  static final ApiService _instance = ApiService._internal();
  ApiService._internal();
  factory ApiService(){return _instance;}

  final String baseUrl = 'http://localhost:8080/api/cryptoVote/';

  Uri _getUri(String endpoint) {return Uri.parse(baseUrl + endpoint);}


  Map<String, String> _headers()
  {
    Map<String, String> headers = HashMap<String, String>();
    headers['content-type'] = 'application/json';


    return headers;
  }



  bool _isUnauthorized(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  void _handleUnAuthorizedAccess() {
    log('Unauthorized access');
  }


  void _logRequest(Uri uri, dynamic body)
  {
    log('Request: $uri');
    log('body: ${body.toString()}');
    if (body != null) log("Request Body: ${jsonEncode(body)}");

  }

  void _logResponse(Uri uri, http.Response response) {
    log('Response: $uri');
    log('Status Code: ${response.statusCode}');
    log('Body: ${response.body}');
  }


  Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestFunction,
      Uri uri, {dynamic body}
      ) async {
    try {
      _logRequest(uri, body);
      final response = await requestFunction();
      _logResponse(uri, response);

      if (_isUnauthorized(response.statusCode)) {
        _handleUnAuthorizedAccess();
      }

      return response; //  Always return response
    } catch (e) {
      log('Error during API call to $uri: $e');

      // Return a dummy error response to satisfy non-null return
      return http.Response('Error: $e', 500);
    }
  }

  Future<http.Response> get(String endpoint, [dynamic body]) async {
    final uri = _getUri(endpoint);
    return _sendRequest(() => http.get(uri,  headers: _headers()), uri);
  }

  Future<http.Response> post(String endpoint, dynamic body) async {
    final uri = _getUri(endpoint);
    return _sendRequest(
            () => http.post(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> put(String endpoint, {dynamic body}) async {
    var uri = _getUri(endpoint);
    return _sendRequest(
            () => http.put(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> delete(String endpoint, {dynamic body}) async {
    var uri = _getUri(endpoint);
    return _sendRequest(
            () => http.delete(uri, headers: _headers(), body: jsonEncode(body)),
        uri,
        body: body);
  }

  Future<http.Response> patch(String endpoint, {dynamic body}) async {
    var uri = _getUri(endpoint);
    return _sendRequest(
            () => http.patch(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> updateProfileImage(
      String imagePath, String endpoint) async {
    var uri = _getUri(endpoint);
    var request = http.MultipartRequest('PATCH', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    request.headers.addAll(_headers());
    _logRequest(uri, {'imagePath': imagePath});
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    _logResponse(uri, response);
    return response;
  }


}