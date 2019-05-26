import 'dart:async';

import 'package:aperture/resources/globals.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:synchronized/synchronized.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../blocs/base_feed_bloc.dart';
import '../../models/post.dart';
import '../utils/post_shared_functions.dart';
import 'image_container.dart';

const double _iconSideSize = 45.0;
const double _defaultHeight = 55.0;

//TODO needs proper refactor to BLOC

class BasicPost extends StatefulWidget {
  final Post post;
  final BaseFeedBloc bloc;

  const BasicPost({Key key, @required this.post, @required this.bloc})
      : super(key: key);

  @override
  _BasicPostState createState() => _BasicPostState(this.post);
}

class _BasicPostState extends State<BasicPost> {
  _BasicPostState(this._post);

  Post _post;
  bool _downIconColor;
  bool _upIconColor;
  final Lock _lock = Lock();

  @override
  void initState() {
    super.initState();
    _setIconColors();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ImageContainer(
            imageUrl: widget.post.image,
            imageHeight: widget.post.height,
            imageWidth: widget.post.width,
            onTap: () => _toDetailedPostScreen(false),
            onDoubleTap: () => _upvoteOrRemove(),
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
                            child: (widget.post.user.avatar == null
                                ? Image.asset(
                                    'assets/img/user_placeholder.png',
                                  )
                                : FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: widget.post.user.avatar,
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
                                  'id': widget.post.user.id,
                                  'name': widget.post.user.name,
                                  'username': widget.post.user.username,
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
                          onTap: () => _upvoteOrRemove(),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.arrowAltCircleUp,
                                  color: _upIconColor
                                      ? Colors.blue
                                      : Colors.grey[600],
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  nFormatter(_post.votes.toDouble(), 0),
                                  style: votesTextStyle(
                                      _upIconColor ? Colors.blue : null),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Material(
                        child: InkWell(
                          onTap: () => _downvoteOrRemove(),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Icon(
                              FontAwesomeIcons.arrowAltCircleDown,
                              color: _downIconColor
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
                      onTap: () => _toDetailedPostScreen(true),
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
                                _post.commentsLength.toString(),
                                style: votesTextStyle(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (int result) {},
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Text("1"),
                          ),
                          const PopupMenuItem<int>(
                            value: 2,
                            child: Text("2"),
                          ),
                          const PopupMenuItem<int>(
                            value: 3,
                            child: Text("3"),
                          ),
                          const PopupMenuItem<int>(
                            value: 4,
                            child: Text("4"),
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

  Future _toDetailedPostScreen(bool toComments) async {
    Post updatedPost = await Navigator.of(context).pushNamed('/detailedPost',
        arguments: {
          'postId': widget.post.id,
          'post': _post,
          'toComments': toComments
        }) as Post;

    setState(() => _post = updatedPost);
  }

  Future _downvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_post.userVote == -1) {
        setState(() {
          _downIconColor = false;
          _post.votes++;
        });

        int result = await widget.bloc.removeVote(widget.post.id);
        if (!mounted) {
          return;
        }

        if (result == 0) {
          setState(() {
            _post.userVote = 0;
          });
        } else {
          setState(() {
            _downIconColor = true;
            _post.votes--;
          });
          /*TODO place dialog here*/
        }
        return;
      }

      setState(() {
        _upIconColor = false;
        _downIconColor = true;
        _post.userVote == 1 ? _post.votes -= 2 : _post.votes--;
      });

      int result = await widget.bloc.downVote(widget.post.id);
      if (!mounted) {
        return;
      }

      if (result == 0) {
        setState(() {
          _post.userVote = -1;
        });
      } else {
        setState(() {
          _upIconColor = true;
          _downIconColor = false;
          _post.userVote == 1 ? _post.votes += 2 : _post.votes++;
        }); /*TODO place dialog here*/
      }
    });
  }

  Future _upvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_post.userVote == 1) {
        setState(() {
          _upIconColor = false;
          _post.votes--;
        });

        int result = await widget.bloc.removeVote(widget.post.id);
        if (!mounted) {
          return;
        }

        if (result == 0) {
          setState(() => _post.userVote = 0);
        } else {
          setState(() {
            _upIconColor = true;
            _post.votes++;
          });
          /*TODO place dialog here*/
        }
        return;
      }
      if (!mounted) {
        return;
      }

      setState(() {
        _upIconColor = true;
        _downIconColor = false;
        _post.userVote == -1 ? _post.votes += 2 : _post.votes++;
      });

      int result = await widget.bloc.upVote(widget.post.id);
      if (!mounted) {
        return;
      }

      if (result == 0) {
        setState(() {
          _post.userVote = 1;
        });
      } else {
        setState(() {
          _upIconColor = false;
          _downIconColor = true;
          _post.userVote == -1 ? _post.votes -= 2 : _post.votes--;
        });
        /*TODO place dialog here*/
      }
    });
  }

  void _setIconColors() {
    switch (_post.userVote) {
      case 0:
        _downIconColor = false;
        _upIconColor = false;
        break;
      case 1:
        _downIconColor = false;
        _upIconColor = true;
        break;
      case -1:
        _downIconColor = true;
        _upIconColor = false;
        break;
      default:
    }
  }
}
