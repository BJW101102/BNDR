import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpHelp {
  static const String url = 'api url';

  //http response helper
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception('bad response: ${response.statusCode}');
    }
  }

  //get helper
  static Future<Map<String, dynamic>> get(String endpoint) async{
    final response = await http.get(Uri.parse('$url/$endpoint'));
    return _handleResponse(response);
  }
}