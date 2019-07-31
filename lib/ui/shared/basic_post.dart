import 'package:aperture/models/post.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/image_container.dart';
import 'package:aperture/utils/post_shared_functions.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

const double _iconSideSize = 45.0;
const double _defaultHeight = 55.0;

TextStyle _votesTextStyle([Color color]) {
  return TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.grey[600],
  );
}

class BasicPost extends StatelessWidget {
  final bool delegatingModel;
  final Post post;

  const BasicPost({Key key, this.delegatingModel = false, this.post})
      : assert((delegatingModel == true && post == null) ||
            (delegatingModel == false && post != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return delegatingModel
        ? Consumer<BasicPostModel>(
            builder: _buildBasicPost,
          )
        : ChangeNotifierBaseView<BasicPostModel>(
            onModelReady: (model) => model.init(post),
            builder: _buildBasicPost,
          );
  }

  Widget _buildBasicPost(
      BuildContext context, BasicPostModel model, Widget __) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ImageContainer(
            imageUrl: model.post.image,
            imageHeight: model.post.height,
            imageWidth: model.post.width,
            onTap: !delegatingModel
                ? () => model.navigateToDetailedPost(context, false)
                : null, // TODO toFullImageScreen
            onDoubleTap: () => model.onUpvoteOrRemove(),
          ),
          Container(
            height: _defaultHeight,
            padding: const EdgeInsets.only(left: 15.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                iconTheme: Theme.of(context)
                    .iconTheme
                    .copyWith(color: Colors.grey[600]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (!delegatingModel)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        height: _iconSideSize,
                        width: _iconSideSize,
                        color: Colors.grey[300],
                        child: Stack(
                          children: <Widget>[
                            model.post.user.avatar == null
                                ? Image.asset('assets/img/user_placeholder.png')
                                : Image.network(model.post.user.avatar),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.white24,
                                onTap: () =>
                                    model.navigateToUserProfile(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Material(
                        child: InkWell(
                          onTap: () => model.onUpvoteOrRemove(),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.arrowAltCircleUp,
                                  color:
                                      model.state == BasicPostViewState.UpVote
                                          ? Colors.blue
                                          : Colors.grey[600],
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  nFormatter(model.post.votes.toDouble(), 0),
                                  style: _votesTextStyle(
                                      model.state == BasicPostViewState.UpVote
                                          ? Colors.blue
                                          : null),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Material(
                        child: InkWell(
                          onTap: () => model.onDownvoteOrRemove(),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Icon(
                              FontAwesomeIcons.arrowAltCircleDown,
                              color: model.state == BasicPostViewState.DownVote
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Material(
                    child: InkWell(
                      onTap: !delegatingModel
                          ? () => model.navigateToDetailedPost(context, true)
                          : null,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 20.0,
                          end: 20.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.commentAlt,
                              size: 18.0,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8.0),
                            Center(
                              child: Text(
                                model.post.commentsLength.toString(),
                                style: _votesTextStyle(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (int value) => model.onSelected(context, value),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<int>(
                          value: 1,
                          child: Row(children: <Widget>[
                            Icon(FontAwesomeIcons.plusSquare),
                            const SizedBox(width: 15.0),
                            const Text('Add to collection'),
                          ]),
                        )
                      ];
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
