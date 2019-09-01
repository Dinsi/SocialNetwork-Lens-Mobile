import 'package:aperture/models/post.dart';
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
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return false;
        },
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

              case TournamentViewState.ActivePhase1:
                return _buildPhase1Setup(context, model);

              case TournamentViewState.ActivePhase2:
                return _buildPhase2Setup(context, model);

              default:
                return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPhase1Setup(BuildContext context, TournamentModel model) {
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
                      side: 60.0,
                      icon: FontAwesomeIcons.arrowAltCircleDown,
                      iconColor: Colors.red,
                      onPressed: () => model.changeVotePh1(
                        context,
                        ChangeVoteAction.Down,
                      ),
                    ),
                    _buildRoundIconButton(
                      side: 60.0,
                      icon: FontAwesomeIcons.arrowAltCircleUp,
                      iconColor: Colors.blue,
                      onPressed: () => model.changeVotePh1(
                        context,
                        ChangeVoteAction.Up,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Column(
        children: <Widget>[
          Text(
            'Upvote or downvote the entries!',
            style: Theme.of(context)
                .textTheme
                .subtitle
                .copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          Text(
            model.tournamentName,
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: model.currentIndex == null
                    ? Text(
                        'Congratulations!\n\n' +
                            'It looks like you already voted for all posts\n' +
                            'Come back later to participate in the final vote',
                        style: Theme.of(context).textTheme.subhead.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      )
                    : model.currentIndex == -1
                        ? Card(
                            child: Center(
                              child: defaultCircularIndicator(),
                            ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPhase2Setup(BuildContext context, TournamentModel model) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              'Pick the best!',
              style: Theme.of(context)
                  .textTheme
                  .subtitle
                  .copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              model.tournamentName,
              style: Theme.of(context).textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: model.listLength,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (_, index) {
                  Post targetPost = model.getPostByIndex(index);
                  final userNames = targetPost.user.name.split(' ');

                  return Card(
                    margin: EdgeInsets.zero,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () =>
                              model.navigateToDetailedPost(context, index),
                          child: Image.network(
                            targetPost.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 0.0,
                          right: 0.0,
                          bottom: 0.0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${userNames[0]}\n${userNames[userNames.length - 1]}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  _buildRoundIconButton(
                                    side: 30.0,
                                    icon: Icons.star,
                                    iconColor: model.userHasVoted &&
                                            model.isVotedPost(index)
                                        ? Colors.amber
                                        : Colors.grey,
                                    onPressed: !model.userHasVoted
                                        ? () =>
                                            model.changeVotePh2(context, index)
                                        : () => showDialog(
                                              context: context,
                                              builder: (context) => Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        primaryColor:
                                                            Colors.red),
                                                child: AlertDialog(
                                                  title:
                                                      const Text('Vote limit'),
                                                  content: const Text(
                                                      'You can only vote once during this phase. Try again in the next tournament'),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: const Text('OK'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRoundIconButton(
      {double side, IconData icon, Color iconColor, VoidCallback onPressed}) {
    return Container(
      width: side,
      height: side,
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
