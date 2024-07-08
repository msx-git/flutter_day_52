import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_day_52/services/firebase/destinations_firebase_service.dart';

class DestinationsController extends ChangeNotifier {
  final _destinationsService = DestinationsFirebaseService();

  Stream<QuerySnapshot> get destinations async* {
    yield* _destinationsService.getDestinations();
  }

  Future<void> addDestinations({
    required File imageFile,
    required String title,
    required String lat,
    required String long,
  }) async {

  }
}
