import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_day_52/models/destination.dart';

class DestinationsFirebaseService {
  final _destinationsCollection =
      FirebaseFirestore.instance.collection('destinations');
  final _destinationsStorage = FirebaseStorage.instance;

  Stream<QuerySnapshot> getDestinations() async* {
    yield* _destinationsCollection.snapshots();
  }

  Future<void> addDestination({
    required File imageFile,
    required String title,
    required String lat,
    required String long,
  }) async {
    final imageRef = _destinationsStorage
        .ref()
        .child('destinations')
        .child("${DateTime.now().microsecondsSinceEpoch}.jpg");

    final uploadTask = imageRef.putFile(imageFile);

    /// Listening to Uploading progress
    uploadTask.snapshotEvents.listen((status) {
      debugPrint("Uploading status: ${status.state}");
      double percentage =
          (status.bytesTransferred / imageFile.lengthSync()) * 100;
      debugPrint("Uploading percentage: $percentage");
    });

    await uploadTask.whenComplete(
      () async {
        final imageUrl = await imageRef.getDownloadURL();
        await _destinationsCollection.add({
          'title': title,
          'imageUrl': imageUrl,
          'lat': lat,
          'long': long,
        });
      },
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
    if (newImage != null) {
      await _destinationsStorage.refFromURL(imageUrl).delete();
      imageUrl = await _uploadProductImage(newImage, newTitle);
    }

    final newDestination = {
      'title': newTitle,
      'imageUrl': imageUrl,
      'lat': newLat,
      'long': newLong,
    };

    await _destinationsCollection.doc(id).update(newDestination);
  }

  Future<void> deleteDestination(Destination destination) async {
    await _destinationsStorage.refFromURL(destination.imageUrl).delete();
    await _destinationsCollection.doc(destination.id).delete();
  }

  Future<String> _uploadProductImage(
    File image,
    String title,
  ) async {
    final imageRef = _destinationsStorage
        .ref()
        .child('destinations')
        .child("${DateTime.now().microsecondsSinceEpoch}.jpg");

    final uploadTask = imageRef.putData(
      image.readAsBytesSync(),
      SettableMetadata(
        contentType: "image/jpeg",
      ),
    );

    await uploadTask.whenComplete(() {});
    return imageRef.getDownloadURL();
  }
}
