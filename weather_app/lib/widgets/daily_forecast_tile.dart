import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyForecastTile extends StatelessWidget {
  final String date;
  final IconData icon;
  final String highTemp;
  final String lowTemp;

  const DailyForecastTile({
    super.key,
    required this.date,
    required this.icon,
    required this.highTemp,
    required this.lowTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat.E().format(DateTime.parse(date)),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Icon(icon, size: 28),
          Text(
            'H: $highTemp° L: $lowTemp°',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
