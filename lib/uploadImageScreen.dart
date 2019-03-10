import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proof_of_concept/api.dart';

class UploadImageButton extends StatelessWidget {
  const UploadImageButton({Key key}) : super(key: key);

  Future<void> _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    Api().upload(image);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Material(
        color: Colors.red,
        child: Container(
            height: 100.0,
            child: InkWell(
              highlightColor: Colors.green,
              splashColor: Colors.green,
              onTap: _getImage,
              child: Center(
                child: Text(
                  'Upload Image',
                  style: Theme.of(context).textTheme.title.copyWith(
                      color: Colors.white
                  ),
                )
              ),
            )
        ),
      ),
    );
  }
}