import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/core/enums/change_vote_action.dart';
import 'package:aperture/view_models/tournament.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TournamentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierBaseView<TournamentModel>(
        onModelReady: (model) => model.init(),
        builder: (context, model, _) {
          switch (model.state) {
            case TournamentViewState.Loading:
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                body: Center(
                  child: defaultCircularIndicator(),
                ),
              );
              break;

            case TournamentViewState.Inactive:
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                body: Center(
                  child: Text(
                    'There is no active tournament\nin progress',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.grey),
                  ),
                ),
              );
              break;

            default:
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                bottomNavigationBar: model.noPostExists
                    ? null
                    : BottomAppBar(
                        color: Colors.transparent,
                        elevation: 0.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              _buildRoundIconButton(
                                icon: FontAwesomeIcons.arrowAltCircleDown,
                                iconColor: Colors.red,
                                onPressed: () => model.changeVote(
                                  context,
                                  ChangeVoteAction.Down,
                                ),
                              ),
                              _buildRoundIconButton(
                                icon: FontAwesomeIcons.arrowAltCircleUp,
                                iconColor: Colors.blue,
                                onPressed: () => model.changeVote(
                                  context,
                                  ChangeVoteAction.Up,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: model.currentIndex == null
                        ? Text(
                            "Congratulations!\n\nIt looks like you already voted for all posts\nCome back later to participate in the final vote",
                            style: Theme.of(context).textTheme.subhead.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          )
                        : Card(
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Center(
                                  child: defaultCircularIndicator(),
                                ),
                                Image.network(
                                  model.currentPost.image,
                                  fit: BoxFit.cover,
                                )
                              ],
                            ),
                          ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildRoundIconButton(
      {IconData icon, Color iconColor, VoidCallback onPressed}) {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x11000000),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: RawMaterialButton(
        shape: CircleBorder(),
        elevation: 0.0,
        child: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
