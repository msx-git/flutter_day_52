import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class DestinationsFirebaseService {
  final _destinationsCollection =
      FirebaseFirestore.instance.collection('destinations');
  final _destinationsStorage = FirebaseStorage.instance;

  Stream<QuerySnapshot> getDestinations() async* {
    yield* _destinationsCollection.snapshots();
  }

  Future<void> addDestinations({
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
          'lan': lat,
          'long': long,
        });
      },
    );
  }
}
