import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_day_52/services/controller/destinations_controller.dart';
import 'package:flutter_day_52/services/location_service.dart';
import 'package:flutter_day_52/views/screens/map_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// PERMISSIONS
  if (!(await Permission.camera.request().isGranted) ||
      !(await Permission.location.request().isGranted)) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
    ].request();
    debugPrint("Permission statuses: $statuses");
  }

  await LocationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DestinationsController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PageView(
          children: [
            MapScreen(),
            // HomeScreen(),
          ],
        ),
      ),
    );
  }
}
