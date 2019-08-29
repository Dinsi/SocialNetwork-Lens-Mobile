import 'package:aperture/utils/utils.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class VoteButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BasicPostModel>(
      builder: (context, model, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildVoteButton(model, true),
            SizedBox(
              width: 50.0,
              child: Center(
                child: Text(
                  nFormatter(model.post.votes.toDouble()),
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: model.state == BasicPostViewState.UpVote
                        ? Colors.blue
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
            _buildVoteButton(model, false),
          ],
        );
      },
    );
  }

  Widget _buildVoteButton(BasicPostModel model, bool isUpvote) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: isUpvote
            ? () => model.onUpvoteOrRemove()
            : () => model.onDownvoteOrRemove(),
        child: Padding(
          padding: isUpvote
              ? const EdgeInsets.symmetric(horizontal: 12.0)
              : const EdgeInsets.only(left: 12.0, right: 8.0),
          child: isUpvote
              ? Icon(
                  FontAwesomeIcons.arrowAltCircleUp,
                  color: model.state == BasicPostViewState.UpVote
                      ? Colors.blue
                      : Colors.grey[600],
                )
              : Icon(
                  FontAwesomeIcons.arrowAltCircleDown,
                  color: model.state == BasicPostViewState.DownVote
                      ? Colors.red
                      : Colors.grey[600],
                ),
        ),
      ),
    );
  }
}