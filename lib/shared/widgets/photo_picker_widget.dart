import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../../core/themes/app_fonts.dart';

Future<XFile?> displayImagePickerDialog(
  BuildContext context,
  // OnPickImageCallback onpick,
) async {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return SizedBox(
        height: 270,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 15.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          "Upload Your Photo",
                          textScaler: const TextScaler.linear(1.0),
                          style: appFonts.subtitle.ts,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: const SizedBox(
                          width: 15,
                          child: Icon(Icons.close),
                        ),
                        onTap: () {
                          Navigator.pop(context, null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      spacing: 7.0,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final XFile? media = await ImagePicker()
                                  .pickImage(
                                    source: ImageSource.gallery,
                                    maxHeight: 1800,
                                    maxWidth: 1800,
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop(media);
                              }
                            },
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Color.fromRGBO(242, 242, 242, 1),
                              ),
                            ),
                            child: Text(
                              "Photo Library",
                              textScaler: const TextScaler.linear(1.0),
                              style: appFonts.ts,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final XFile? media = await ImagePicker()
                                  .pickImage(
                                    source: ImageSource.camera,
                                    maxHeight: 1800,
                                    maxWidth: 1800,
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop(media);
                              }
                            },
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Color.fromRGBO(242, 242, 242, 1),
                              ),
                            ),
                            child: Text(
                              "Take Photo",
                              textScaler: const TextScaler.linear(1.0),
                              style: appFonts.ts,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Color.fromRGBO(242, 242, 242, 1),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              textScaler: const TextScaler.linear(1.0),
                              style: appFonts.error.ts,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

typedef OnPickImageCallback =
    void Function(int? type, double? maxWidth, double? maxHeight, int? quality);
