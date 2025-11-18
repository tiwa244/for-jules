import 'package:flutter/material.dart';

IconData getWeatherIcon(int weatherCode) {
  switch (weatherCode) {
    case 0:
      return Icons.wb_sunny; // Clear sky
    case 1:
    case 2:
    case 3:
      return Icons.cloud; // Mainly clear, partly cloudy, and overcast
    case 45:
    case 48:
      return Icons.foggy; // Fog and depositing rime fog
    case 51:
    case 53:
    case 55:
      return Icons.grain; // Drizzle: Light, moderate, and dense intensity
    case 56:
    case 57:
      return Icons.ac_unit; // Freezing Drizzle: Light and dense intensity
    case 61:
    case 63:
    case 65:
      return Icons.beach_access; // Rain: Slight, moderate and heavy intensity
    case 66:
    case 67:
      return Icons.ac_unit; // Freezing Rain: Light and heavy intensity
    case 71:
    case 73:
    case 75:
      return Icons.ac_unit; // Snow fall: Slight, moderate, and heavy intensity
    case 77:
      return Icons.ac_unit; // Snow grains
    case 80:
    case 81:
    case 82:
      return Icons.beach_access; // Rain showers: Slight, moderate, and violent
    case 85:
    case 86:
      return Icons.ac_unit; // Snow showers slight and heavy
    case 95:
      return Icons.bolt; // Thunderstorm: Slight or moderate
    case 96:
    case 99:
      return Icons.bolt; // Thunderstorm with slight and heavy hail
    default:
      return Icons.help; // Default icon
  }
}
