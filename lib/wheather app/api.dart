import 'package:dio/dio.dart';
import 'model.dart';

class WeatherService {
  final Dio _dio = Dio();
  final String apiUrl =
      'https://api.openbrewerydb.org/breweries'; // Example API

  Future<List<Weather>> fetchWeather() async {
    try {
      Response response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Weather.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
