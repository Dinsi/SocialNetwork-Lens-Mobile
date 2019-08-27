import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/tournament.dart';
import 'package:flutter/material.dart';

class TournamentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierBaseView<TournamentModel>(
          onModelReady: (model) => model.init(),
          builder: (context, model, _) {
            switch (model.state) {
              case TournamentViewState.Loading:
                return Center(child: defaultCircularIndicator());
                break;

              case TournamentViewState.Inactive:
                return Center(
                  child: Text(
                    'There is no active tournament\nin progress',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.grey),
                  ),
                );
                break;

              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
