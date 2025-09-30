import 'dart:convert';
import 'package:http/http.dart' as http;

class AirService {
  final String token =
      "8e824418cbde40ea3a572d156386a168c9ec0c99"; 
  final String city = "bangkok";

  Future<Map<String, dynamic>> fetchAirQuality() async {
    final url = Uri.parse("https://api.waqi.info/feed/$city/?token=$token");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        "aqi": data["data"]["aqi"],
        "city": data["data"]["city"]["name"],
        "temperature": data["data"]["iaqi"]["t"]["v"],
      };
    } else {
      throw Exception("Failed to fetch data");
    }
  }
}
