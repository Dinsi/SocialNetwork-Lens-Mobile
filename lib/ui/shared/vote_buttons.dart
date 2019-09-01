import 'package:aperture/utils/utils.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

const _defaultColor = Color(0xFF757575); //Colors.grey[600]

class VoteButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);

    return Consumer<BasicPostModel>(
      builder: (context, model, _) {
        return IconTheme(
          data: iconTheme.copyWith(color: _defaultColor),
          child: Row(
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
                          : model.state == BasicPostViewState.DownVote
                              ? Colors.red
                              : _defaultColor,
                    ),
                  ),
                ),
              ),
              _buildVoteButton(model, false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoteButton(BasicPostModel model, bool isUpvote) {
    return InkWell(
      onTap: isUpvote
          ? () => model.onUpvoteOrRemove()
          : () => model.onDownvoteOrRemove(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: isUpvote
            ? Icon(
                FontAwesomeIcons.arrowAltCircleUp,
                color: model.state == BasicPostViewState.UpVote
                    ? Colors.blue
                    : null,
              )
            : Icon(
                FontAwesomeIcons.arrowAltCircleDown,
                color: model.state == BasicPostViewState.DownVote
                    ? Colors.red
                    : null,
              ),
      ),
    );
  }
}
