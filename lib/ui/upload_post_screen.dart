import 'dart:async';
import 'dart:io';

import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/view_models/upload_post.dart';
import 'package:flutter/material.dart';

class UploadPostScreen extends StatelessWidget {
  final File file;

  const UploadPostScreen({this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ChangeNotifierBaseView<UploadPostModel>(
        onModelReady: (model) => model.init(file),
        builder: (context, model, _) {
          return WillPopScope(
            onWillPop: () =>
                Future.value(model.state == UploadPostViewState.Idle),
            child: Scaffold(
              key: model.scaffoldKey,
              appBar: AppBar(
                title: const Text('New Post'),
                actions: <Widget>[
                  FlatButton.icon(
                    icon: Icon(
                      Icons.check,
                      color: model.state == UploadPostViewState.Idle
                          ? Colors.red
                          : Colors.grey,
                    ),
                    label: Text(
                      model.state == UploadPostViewState.Idle
                          ? 'UPLOAD'
                          : 'UPLOADING',
                      style: Theme.of(context).textTheme.button.copyWith(
                            color: model.state == UploadPostViewState.Idle
                                ? Colors.red
                                : Colors.grey,
                          ),
                    ),
                    onPressed: model.state == UploadPostViewState.Idle
                        ? () => model.uploadPost(context)
                        : null,
                  ),
                ],
              ),
              body: Theme(
                data: theme.copyWith(primaryColor: Colors.red),
                child: ListView(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => model.loadImage(),
                      child: Image.file(model.image, fit: BoxFit.fitWidth),
                    ),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: model.titleTextController,
                            decoration: InputDecoration(labelText: "Title"),
                            keyboardType: TextInputType.text,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(model.descriptionFocusNode),
                            maxLength: 128,
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            controller: model.descriptionTextController,
                            focusNode: model.descriptionFocusNode,
                            decoration: InputDecoration(
                              labelText: "Description",
                              alignLabelWithHint: true,
                            ),
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            maxLength: 1024,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
