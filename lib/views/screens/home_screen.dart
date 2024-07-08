import 'package:flutter/material.dart';
import 'package:flutter_day_52/models/destinations.dart';
import 'package:flutter_day_52/services/controller/destinations_controller.dart';
import 'package:flutter_day_52/views/widgets/add_destination_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(
  //     Duration.zero,
  //     () async {
  //       await LocationService.getCurrentLocation().then((_) => setState(() {}));
  //     },
  //   );
  // }

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

          return ListView.builder(
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination =
                  Destinations.fromSnapshot(destinations[index]);
              return ListTile(
                leading: Image.network(destination.imageUrl),
                title: Text(destination.title),
                subtitle:
                    Text("lat: ${destination.lat}\nlong: ${destination.long}"),
                isThreeLine: true,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddDestinationDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
