import 'package:flutter/material.dart';
import 'package:flutter_day_52/models/destination.dart';
import 'package:flutter_day_52/utils/extensions.dart';

class DestinationDetails extends StatelessWidget {
  const DestinationDetails(
      {super.key, required this.destination, required this.index});

  final Destination destination;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(destination.title)),
      body: Column(
        children: [
          Hero(
            tag: 'destinationImage1$index',
            child: Image.network(destination.imageUrl),
          ),
          Expanded(
            child: Center(
              child: Text(
                destination.title,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Text(
            "Latitude: ${destination.lat}\nLongitude: ${destination.long}",
            style: const TextStyle(fontSize: 16),
          ),
          20.height,
        ],
      ),
    );
  }
}
