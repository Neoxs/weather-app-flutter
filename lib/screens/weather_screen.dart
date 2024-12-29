// lib/screens/weather_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  WeatherModel? _currentWeather;
  List<WeatherModel>? _forecast;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _getWeatherData(String city) async {
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final current = await _weatherService.getCurrentWeather(city);
      final forecast = await _weatherService.getForecast(city);
      setState(() {
        _currentWeather = current;
        _forecast = forecast;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load weather data. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[400]!, Colors.blue[900]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (_currentWeather != null)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _getWeatherData(_currentWeather!.cityName),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildCurrentWeather(),
                          _buildForecast(),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      'Enter a city name to get weather information',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: _cityController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter city name',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () => _cityController.clear(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onSubmitted: _getWeatherData,
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _currentWeather!.cityName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _currentWeather!.formattedDate,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          Image.network(
            'https://openweathermap.org/img/wn/${_currentWeather!.iconCode}@4x.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.cloud,
              size: 120,
              color: Colors.white,
            ),
          ),
          Text(
            '${_currentWeather!.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _currentWeather!.description.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherInfo(
                FontAwesomeIcons.water,
                '${_currentWeather!.humidity}%',
                'Humidity',
              ),
              _buildWeatherInfo(
                FontAwesomeIcons.umbrella,
                '${_currentWeather!.precipitation}mm',
                'Rain',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        FaIcon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildForecast() {
    if (_forecast == null || _forecast!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '7-Day Forecast',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _forecast!.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return DetailedForecastCard(forecast: _forecast![index]);
          },
        ),
      ],
    );
  }
}

class DetailedForecastCard extends StatelessWidget {
  final WeatherModel forecast;

  const DetailedForecastCard({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(forecast.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(forecast.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Image.network(
                    'https://openweathermap.org/img/wn/${forecast.iconCode}@2x.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.cloud,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${forecast.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.water,
                            size: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${forecast.humidity}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}