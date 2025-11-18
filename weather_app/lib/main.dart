import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:weather_app/utils/weather_icons.dart';
import 'package:weather_app/widgets/daily_forecast_tile.dart';
import 'package:weather_app/widgets/hourly_forecast_card.dart';
import 'package:weather_app/widgets/summary_data_point_card.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        cardColor: const Color(0xFF2B2B2B),
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? _weatherData;
  String _locationName = 'Current Location';
  Location location = Location();

  @override
  void initState() {
    super.initState();
    _getLocationAndFetchWeather();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _getLocationAndFetchWeather() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showErrorSnackBar('Location services are disabled.');
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _showErrorSnackBar('Location permission denied.');
          return;
        }
      }

      locationData = await location.getLocation();
      _fetchWeatherData(locationData.latitude, locationData.longitude);
    } catch (e) {
      _showErrorSnackBar('Failed to get location: $e');
    }
  }

  Future<void> _fetchWeatherData(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      return;
    }
    try {
      final response = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,apparent_temperature,weathercode,relativehumidity_2m,windspeed_10m,precipitation_probability,uv_index&daily=weathercode,temperature_2m_max,temperature_2m_min&current_weather=true&timezone=auto'));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
        });
      } else {
        _showErrorSnackBar('Failed to load weather data');
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching weather data: $e');
    }
  }
    Future<void> _searchLocation(String cityName) async {
    if (cityName.isEmpty) {
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1'));

      if (response.statusCode == 200) {
        final results = json.decode(response.body)['results'];
        if (results != null && results.isNotEmpty) {
          final lat = results[0]['latitude'];
          final lon = results[0]['longitude'];
          final name = results[0]['name'];
          setState(() {
            _locationName = name;
          });
          _fetchWeatherData(lat, lon);
        }
      } else {
        _showErrorSnackBar('Failed to search for location');
      }
    } catch (e) {
      _showErrorSnackBar('Error searching for location: $e');
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: const Text('Search for a location'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter city name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _searchLocation(_controller.text);
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_locationName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: _weatherData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMainTemperature(),
                    const SizedBox(height: 24),
                    _buildInsights(),
                    const SizedBox(height: 24),
                    _buildQuickSummary(),
                    const SizedBox(height: 24),
                    _buildHourlyForecast(),
                    const SizedBox(height: 24),
                    _buildTenDayForecast(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMainTemperature() {
    final currentWeather = _weatherData?['current_weather'];
    final daily = _weatherData?['daily'];
    final temperature = currentWeather?['temperature']?.toStringAsFixed(0) ?? 'N/A';
    final feelsLike = _weatherData?['hourly']?['apparent_temperature']?[DateTime.now().hour]?.toStringAsFixed(0) ?? 'N/A';
    final highTemp = daily?['temperature_2m_max']?[0]?.toStringAsFixed(0) ?? 'N/A';
    final lowTemp = daily?['temperature_2m_min']?[0]?.toStringAsFixed(0) ?? 'N/A';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Text('$temperature°', style: const TextStyle(fontSize: 96)),
            Text('Feels like $feelsLike°'),
            Text('H: $highTemp° L: $lowTemp°'),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Insights: The weather today will be pleasant.'),
      ),
    );
  }

  Widget _buildQuickSummary() {
    final hourly = _weatherData?['hourly'];
    final windSpeed = hourly?['windspeed_10m']?[DateTime.now().hour]?.toStringAsFixed(0) ?? 'N/A';
    final humidity = hourly?['relativehumidity_2m']?[DateTime.now().hour]?.toStringAsFixed(0) ?? 'N/A';
    final precipProb = hourly?['precipitation_probability']?[DateTime.now().hour]?.toStringAsFixed(0) ?? 'N/A';
    final uvIndex = hourly?['uv_index']?[DateTime.now().hour]?.toStringAsFixed(1) ?? 'N/A';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        SummaryDataPointCard(icon: Icons.air, title: 'Wind', value: '$windSpeed km/h'),
        SummaryDataPointCard(icon: Icons.water_drop, title: 'Humidity', value: '$humidity%'),
        SummaryDataPointCard(icon: Icons.umbrella, title: 'Precipitation', value: '$precipProb%'),
        SummaryDataPointCard(icon: Icons.wb_sunny, title: 'UV Index', value: uvIndex),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    final hourly = _weatherData?['hourly'];
    if (hourly == null) {
      return const SizedBox.shrink();
    }
    final times = (hourly['time'] as List).cast<String>();
    final temperatures = (hourly['temperature_2m'] as List).cast<double>();
    final weatherCodes = (hourly['weathercode'] as List).cast<int>();

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: HourlyForecastCard(
              time: times[index],
              icon: getWeatherIcon(weatherCodes[index]),
              temperature: temperatures[index].toStringAsFixed(0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTenDayForecast() {
    final daily = _weatherData?['daily'];
    if (daily == null) {
      return const SizedBox.shrink();
    }
    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<double>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<double>();
    final weatherCodes = (daily['weathercode'] as List).cast<int>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('10-Day Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: times.length,
              itemBuilder: (context, index) {
                return DailyForecastTile(
                  date: times[index],
                  icon: getWeatherIcon(weatherCodes[index]),
                  highTemp: maxTemps[index].toStringAsFixed(0),
                  lowTemp: minTemps[index].toStringAsFixed(0),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
