import 'package:aperture/ui/base_view.dart';
import 'package:aperture/view_models/startup_model.dart';
import 'package:flutter/material.dart';

class StartUpWidget extends StatelessWidget {
  const StartUpWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleBaseView<StartUpModel>(
        onModelReady: (model) => model.getStartRoute().then((routeName) =>
            Navigator.of(context).pushReplacementNamed(routeName)),
        builder: (_, model, __) {
          return const Scaffold(
            body: const Center(
              child: const CircularProgressIndicator(),
            ),
          );
        });
  }
}
