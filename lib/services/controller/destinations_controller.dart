import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_day_52/services/firebase/destinations_firebase_service.dart';

import '../../models/destination.dart';

class DestinationsController extends ChangeNotifier {
  final _destinationsService = DestinationsFirebaseService();

  Stream<QuerySnapshot> get destinations async* {
    yield* _destinationsService.getDestinations();
  }

  Future<void> addDestination({
    required File imageFile,
    required String title,
    required String lat,
    required String long,
  }) async {
    await _destinationsService.addDestination(
      imageFile: imageFile,
      title: title,
      lat: lat,
      long: long,
    );
  }

  Future<void> editDestination({
    required String id,
    required String newTitle,
    required String imageUrl,
    required String newLat,
    required String newLong,
    required File? newImage,
  }) async {
    await _destinationsService.editDestination(
      id: id,
      newTitle: newTitle,
      imageUrl: imageUrl,
      newLat: newLat,
      newLong: newLong,
      newImage: newImage,
    );
  }

  Future<void> deleteDestination(Destination destination) async {
    await _destinationsService.deleteDestination(destination);
  }
}
