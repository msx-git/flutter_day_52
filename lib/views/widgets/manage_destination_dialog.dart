import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_day_52/models/destination.dart';
import 'package:flutter_day_52/services/controller/destinations_controller.dart';
import 'package:flutter_day_52/utils/extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../services/location_service.dart';
import '../../utils/show_loader.dart';
import 'my_text_form_field.dart';

class ManageDestinationDialog extends StatefulWidget {
  const ManageDestinationDialog({super.key, this.destination});

  final Destination? destination;

  @override
  State<ManageDestinationDialog> createState() =>
      _ManageDestinationDialogState();
}

class _ManageDestinationDialogState extends State<ManageDestinationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  File? _imageFile;
  var _myLocation = LocationService.currentLocation;

  void openGallery() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      requestFullMetadata: false,
    );

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void openCamera() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      requestFullMetadata: false,
    );

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void addDestination() async {
    Messages.showLoadingDialog(context);
    await context
        .read<DestinationsController>()
        .addDestination(
          imageFile: _imageFile!,
          title: _titleController.text,
          lat: _myLocation!.latitude.toString(),
          long: _myLocation!.longitude.toString(),
        )
        .then(
      (value) {
        _titleController.clear();
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  void updateDestination() async {
    Messages.showLoadingDialog(context);
    await context
        .read<DestinationsController>()
        .editDestination(
          id: widget.destination!.id,
          imageUrl: widget.destination!.imageUrl,
          newImage: _imageFile!,
          newTitle: _titleController.text,
          newLat: _myLocation!.latitude.toString(),
          newLong: _myLocation!.longitude.toString(),
        )
        .then(
      (value) {
        _titleController.clear();
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.destination?.title ?? "");
    Future.delayed(
      Duration.zero,
      () async {
        await LocationService.getCurrentLocation().then((_) => setState(() {}));
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _myLocation = LocationService.currentLocation;
    return AlertDialog(
      scrollable: true,
      title: Text(widget.destination == null
          ? "Add a destination"
          : "Edit the destination"),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTextFormField(
              label: widget.destination == null
                  ? "Destination title"
                  : "New destination title",
              controller: _titleController,
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return widget.destination == null
                      ? "Please, enter title of destination!"
                      : "Please, enter new title of the destination!";
                }
                return null;
              },
            ),
            10.height,
            Text(
              widget.destination == null
                  ? "Add picture"
                  : "Replace with new picture",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: openCamera,
                  label: const Text("Camera"),
                  icon: const Icon(Icons.camera),
                ),
                TextButton.icon(
                  onPressed: openGallery,
                  label: const Text("Gallery"),
                  icon: const Icon(Icons.image),
                ),
              ],
            ),
            if (_imageFile != null)
              SizedBox(
                height: 150,
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Lat: ${_myLocation?.latitude?.toStringAsFixed(3) ?? "loading"}\nLong: ${_myLocation?.longitude?.toStringAsFixed(3) ?? "loading"}"),
                ElevatedButton(
                  onPressed: () async {
                    await LocationService.getCurrentLocation();
                    setState(() {});
                  },
                  child: const Text("Get location"),
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed:
              widget.destination == null ? addDestination : updateDestination,
          child: Text(widget.destination == null ? "Add" : "Save"),
        ),
      ],
    );
  }
}
