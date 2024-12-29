// lib/models/weather_model.dart
import 'package:intl/intl.dart';

class WeatherModel {
  final String cityName;
  final DateTime date;
  final double temperature;
  final int humidity;
  final double precipitation;
  final String description;
  final String iconCode;

  WeatherModel({
    required this.cityName,
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.description,
    required this.iconCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      temperature: (json['main']?['temp'] ?? 0.0).toDouble(),
      humidity: json['main']?['humidity'] ?? 0,
      precipitation: (json['rain']?['1h'] ?? 0.0).toDouble(),
      description: json['weather']?[0]?['description'] ?? '',
      iconCode: json['weather']?[0]?['icon'] ?? '01d',
    );
  }

  String get formattedDate => DateFormat('EEEE, MMM d, yyyy').format(date);
}