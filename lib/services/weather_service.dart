import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = 'e4cbf15249fb4e4a5caa3e069c47f091'; // Replace with your OpenWeatherMap API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> getCurrentWeather(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<WeatherModel>> getForecast(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forecast?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['list'];
      
      var forecasts = <WeatherModel>[];
      var currentDate = DateTime.now();
      var processedDates = <String>{};

      // Sort the list by datetime to ensure chronological order
      list.sort((a, b) => (a['dt']).compareTo(b['dt']));

      // Process each item in the list
      for (var item in list) {
        var itemDate = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        var dateStr = '${itemDate.year}-${itemDate.month}-${itemDate.day}';

        // Skip if it's before today
        if (itemDate.isBefore(DateTime(currentDate.year, currentDate.month, currentDate.day))) {
          continue;
        }

        // Add the first reading of each new day until we have 7 days
        if (!processedDates.contains(dateStr) && forecasts.length < 7) {
          forecasts.add(WeatherModel.fromJson({
            ...item,
            'name': data['city']['name'],
          }));
          processedDates.add(dateStr);
        }

        // Break if we have collected 7 days
        if (forecasts.length >= 7) {
          break;
        }
      }

      // Sort the forecasts by date to ensure proper order
      forecasts.sort((a, b) => a.date.compareTo(b.date));
      
      return forecasts;
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}