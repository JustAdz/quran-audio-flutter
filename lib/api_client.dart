import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<Map<String, dynamic>> process(String url) async {
    final resp = await http.post(Uri.parse("http://localhost:8000/process"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"youtube_url": url}));
    return json.decode(resp.body);
  }
}
