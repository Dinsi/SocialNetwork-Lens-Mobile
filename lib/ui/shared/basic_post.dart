import 'package:aperture/models/post.dart';
import 'package:aperture/router.dart';
import 'package:aperture/ui/base_view.dart';
import 'package:aperture/ui/shared/image_container.dart';
import 'package:aperture/utils/post_shared_functions.dart';
import 'package:aperture/view_models/shared/basic_post_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

const double _iconSideSize = 45.0;
const double _defaultHeight = 55.0;

class BasicPost extends StatelessWidget {
  final bool delegatingToDetail;
  final Post post;

  const BasicPost({Key key, @required this.delegatingToDetail, this.post})
      : assert((delegatingToDetail == true && post == null) ||
            (delegatingToDetail == false && post != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return delegatingToDetail
        ? Consumer<BasicPostModel>(
            builder: _buildBasicPost,
          )
        : ChangeNotifierBaseView<BasicPostModel>(
            onModelReady: (model) => model.setPost(post),
            builder: _buildBasicPost,
          );
  }

  Widget _buildBasicPost(
      BuildContext context, BasicPostModel model, Widget __) {
    return Container(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ImageContainer(
            imageUrl: model.post.image,
            imageHeight: model.post.height,
            imageWidth: model.post.width,
            onTap: !delegatingToDetail
                ? () => model.navigateToDetailedPost(context, false)
                : null, // TODO toFullImageScreen
            onDoubleTap: () => model.onUpvoteOrRemove(),
          ),
          Container(
            height: _defaultHeight,
            padding: const EdgeInsets.only(left: 15.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                iconTheme: Theme.of(context).iconTheme.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (!delegatingToDetail)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        height: _iconSideSize,
                        width: _iconSideSize,
                        color: Colors.grey[300],
                        child: Stack(
                          children: <Widget>[
                            model.post.user.avatar == null
                                ? Image.asset(
                                    'assets/img/user_placeholder.png',
                                  )
                                : FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: model.post.user.avatar,
                                  ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.white24,
                                  onTap: () =>
                                      model.navigateToUserProfile(context)),
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
                                  style: votesTextStyle(
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
                      onTap: !delegatingToDetail
                          ? () => model.navigateToDetailedPost(context, true)
                          : null,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 20.0, end: 20.0),
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
                                style: votesTextStyle(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (int value) => model.onSelected(context, value),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                      PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.plusSquare,
                            ),
                            const SizedBox(width: 15.0),
                            Text('Add to collection'),
                          ],
                        ),
                      ),
                    ],
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
