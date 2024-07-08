import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_day_52/services/controller/destinations_controller.dart';
import 'package:flutter_day_52/utils/extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../services/location_service.dart';
import '../../utils/show_loader.dart';
import 'my_text_form_field.dart';

class AddDestinationDialog extends StatefulWidget {
  const AddDestinationDialog({super.key});

  @override
  State<AddDestinationDialog> createState() => _AddDestinationDialogState();
}

class _AddDestinationDialogState extends State<AddDestinationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
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

  void addCategory() async {
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

  @override
  void initState() {
    super.initState();
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
      title: const Text("Add a destination"),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTextFormField(
              label: "Destination title",
              controller: _titleController,
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return "Please, enter title of destination!";
                }
                return null;
              },
            ),
            10.height,
            const Text(
              "Add picture",
              style: TextStyle(fontWeight: FontWeight.bold),
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
                    "Lat: ${_myLocation?.latitude?.toStringAsFixed(3)}\nLong: ${_myLocation?.longitude?.toStringAsFixed(3)}"),
                ElevatedButton(
                  onPressed: () async {
                    await LocationService.getCurrentLocation();
                    setState(() {});
                  },
                  child: Text("Get location"),
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
          onPressed: addCategory,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
