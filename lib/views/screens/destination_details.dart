import 'package:flutter/material.dart';
import 'package:flutter_day_52/models/destination.dart';
import 'package:flutter_day_52/services/controller/destinations_controller.dart';
import 'package:flutter_day_52/utils/extensions.dart';
import 'package:provider/provider.dart';

import '../../utils/show_loader.dart';
import '../widgets/manage_destination_dialog.dart';

class DestinationDetails extends StatelessWidget {
  const DestinationDetails(
      {super.key, required this.destination, required this.index});

  final Destination destination;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(destination.title),
        actions: [
          IconButton(
            onPressed: () async {
              Messages.showLoadingDialog(context);
              await context
                  .read<DestinationsController>()
                  .deleteDestination(destination)
                  .then(
                (_) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              );
            },
            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ManageDestinationDialog(
                destination: destination,
              ),
            ),
            icon: const Icon(Icons.edit_note_rounded, color: Colors.teal),
          ),
        ],
      ),
      body: Column(
        children: [
          Hero(
            tag: 'destinationImage1$index',
            child: Image.network(destination.imageUrl),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Center(
                child: FittedBox(
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
