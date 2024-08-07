import 'package:flutter/material.dart';
import 'package:flutter_day_52/views/widgets/manage_destination_dialog.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../services/controller/destinations_controller.dart';
import 'destination_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // final myLocation = LocationService.currentLocation;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinations'),
      ),
      body: StreamBuilder(
        stream: context.read<DestinationsController>().destinations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("Couldn't fetch destinations."),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No destinations found."),
            );
          }

          final destinations = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 100 / 170,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = Destination.fromSnapshot(destinations[index]);
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationDetails(
                        destination: destination, index: index),
                  ),
                ),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'destinationImage1$index',
                        child: Image.network(
                          destination.imageUrl,
                          height: 250,
                          fit: BoxFit.cover,
                          width: 210,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Center(
                            child: FittedBox(
                              child: Text(
                                destination.title,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const ManageDestinationDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
