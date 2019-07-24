import 'package:aperture/models/post.dart';
import 'package:aperture/ui/base_view.dart';
import 'package:aperture/ui/shared/image_container.dart';
import 'package:aperture/utils/post_shared_functions.dart';
import 'package:aperture/view_models/feed/basic_post_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

const double _iconSideSize = 45.0;
const double _defaultHeight = 55.0;

class BasicPost extends StatelessWidget {
  final Post post;

  const BasicPost({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBaseView<BasicPostModel>(
      onModelReady: (model) => model.setPost(post),
      builder: (_, model, __) {
        return Container(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ImageContainer(
                imageUrl: model.post.image,
                imageHeight: model.post.height,
                imageWidth: model.post.width,
                onTap: /* TODO () => model.toDetailedPostScreen(false) */ null,
                onDoubleTap: () => model.upvoteOrRemove(),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          height: _iconSideSize,
                          width: _iconSideSize,
                          color: Colors.grey[300],
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: (model.post.user.avatar == null
                                    ? Image.asset(
                                        'assets/img/user_placeholder.png',
                                      )
                                    : FadeInImage.memoryNetwork(
                                        placeholder: kTransparentImage,
                                        image: model.post.user.avatar,
                                      )),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.white24,
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed('/userProfile', arguments: {
                                      'id': model.post.user.id,
                                      'username': model.post.user.username,
                                    });
                                  },
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
                              onTap: () => model.upvoteOrRemove(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.arrowAltCircleUp,
                                      color: model.state ==
                                              BasicPostViewState.UpVote
                                          ? Colors.blue
                                          : Colors.grey[600],
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      nFormatter(
                                          model.post.votes.toDouble(), 0),
                                      style: votesTextStyle(model.state ==
                                              BasicPostViewState.UpVote
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
                              onTap: () => model.downvoteOrRemove(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Icon(
                                  FontAwesomeIcons.arrowAltCircleDown,
                                  color:
                                      model.state == BasicPostViewState.DownVote
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
                          onTap: /* TODO () => model.toDetailedPostScreen(true),*/ null,
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
                        onSelected: (int value) async {
                          if (value == 1) {
                            String collectionName =
                                await Navigator.of(context).pushNamed(
                              '/collectionList',
                              arguments: {
                                'addToCollection': true,
                                'postId': model.post.id,
                              },
                            );

                            if (collectionName != null) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Add to collection'),
                                    content: Text(
                                        'Post has been added to $collectionName'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('OK'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
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
      },
    );
  }
}
