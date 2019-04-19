import 'package:aperture/models/comment.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/network/api.dart';
import 'package:aperture/widgets/posts/comment_tile.dart';
import 'package:aperture/widgets/posts/image_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:synchronized/synchronized.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:aperture/utils/post_shared_functions.dart';

const double _votesTabHeight = 45.0;
const double _iconSideSize = 60.0;
const double _defaultHeight = 75.0;

class DetailedPostScreen extends StatefulWidget {
  final Post post;
  final bool toComments;

  const DetailedPostScreen({@required this.post, @required this.toComments});

  @override
  _DetailedPostScreenState createState() =>
      _DetailedPostScreenState(post.userVote);
}

class _DetailedPostScreenState extends State<DetailedPostScreen> {
  _DetailedPostScreenState(this._votes);

  GlobalKey _columnKey = GlobalKey();
  int _votes;
  int _currentVote;
  bool _downIconColor;
  bool _upIconColor;
  List<Comment> _comments;
  ScrollController _scrollController;
  final Lock _lock = Lock();
  double _initialHeight;

  @override
  void initState() {
    super.initState();
    _setIconColors();
    _getComments();
    _scrollController = ScrollController();
    if (widget.toComments) {
      WidgetsBinding.instance.addPostFrameCallback(_getInitialHeight);
    }
  }

  void _getInitialHeight(_) {
    final RenderBox renderBoxColumn =
        _columnKey.currentContext.findRenderObject();
    _initialHeight = renderBoxColumn.size.height;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            height: _iconSideSize,
            width: _iconSideSize,
            color: Colors.grey[300],
            child: (widget.post.user.avatar == null
                ? Image.asset(
                    'assets/img/user_placeholder.png',
                  )
                : FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: widget.post.user.avatar,
                  )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(
            widget.post.user.name,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    var buttons = Container(
      width: 50.0,
      height: _defaultHeight - 20.0,
      color: Colors.red,
    );

    var descriptionText = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        widget.post.description,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    );

    var imageContainer = ImageContainer(
      imageUrl: widget.post.image,
      imageHeight: widget.post.height,
      imageWidth: widget.post.width,
      onTap: /*TODO _toFullImageScreen*/ null,
      onDoubleTap: () => _upvoteOrRemove(),
    );

    var votesTab = Material(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: _votesTabHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Material(
                    child: InkWell(
                      onTap: () => _upvoteOrRemove(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.arrowAltCircleUp,
                              color:
                                  _upIconColor ? Colors.blue : Colors.grey[600],
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              nFormatter(_votes.toDouble(), 0),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(
                          FontAwesomeIcons.arrowAltCircleDown,
                          color: _downIconColor ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FlatButton.icon(
                    color: Colors.transparent,
                    icon: Icon(
                      FontAwesomeIcons.commentAlt,
                      size: 18.0,
                      color: Colors.grey[600],
                    ),
                    label: Text(
                      widget.post.commentsLength.toString(),
                      style: votesTextStyle(),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              PopupMenuButton<int>(
                onSelected: (int result) {},
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
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
              ),
            ],
          ),
        ),
      ),
    );

    List<Widget> listOfWidgets = [
      Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
        child: Container(
          height: _defaultHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[userRow, buttons],
          ),
        ),
      ),
      descriptionText,
      imageContainer,
      votesTab,
    ];

    if (_comments != null) {
      listOfWidgets = _addCommentWidgets(listOfWidgets);
    }

    return SafeArea(
      child: Scaffold(
        body: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              key: _columnKey,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: listOfWidgets,
            ),
          ),
        ),
      ),
    );
  }

  Future _downvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_currentVote == -1) {
        setState(() {
          _downIconColor = false;
          _votes++;
        });

        int result = await Api.removeVote(widget.post.id);
        if (result == 0) {
          setState(() {
            _currentVote = 0;
          });
        } else {
          setState(() {
            _downIconColor = true;
            _votes--;
          });
          /*TODO place dialog here*/
        }
        return;
      }

      setState(() {
        _upIconColor = false;
        _downIconColor = true;
        _currentVote == 1 ? _votes -= 2 : _votes--;
      });

      int result = await Api.downVote(widget.post.id);
      if (result == 0) {
        setState(() {
          _currentVote = -1;
        });
      } else {
        setState(() {
          _upIconColor = true;
          _downIconColor = false;
          _currentVote == 1 ? _votes += 2 : _votes++;
        }); /*TODO place dialog here*/
      }
    });
  }

  Future _upvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_currentVote == 1) {
        setState(() {
          _upIconColor = false;
          _votes--;
        });

        int result = await Api.removeVote(widget.post.id);
        if (result == 0) {
          setState(() {
            _currentVote = 0;
          });
        } else {
          setState(() {
            _upIconColor = true;
            _votes++;
          });
          /*TODO place dialog here*/
        }
        return;
      }

      setState(() {
        _upIconColor = true;
        _downIconColor = false;
        _currentVote == -1 ? _votes += 2 : _votes++;
      });

      int result = await Api.upVote(widget.post.id);
      if (result == 0) {
        setState(() {
          _currentVote = 1;
        });
      } else {
        setState(() {
          _upIconColor = false;
          _downIconColor = true;
          _currentVote == -1 ? _votes -= 2 : _votes--;
        });
        /*TODO place dialog here*/
      }
    });
  }

  void _setIconColors() {
    switch (widget.post.userVote) {
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
    _currentVote = widget.post.userVote;
  }

  Future _getComments() async {
    List<Comment> comments = await Api.comments(widget.post.id);
    if (comments.isNotEmpty) {
      setState(() {
        _comments = comments;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.toComments) {
          if (_scrollController.position.maxScrollExtent <= _initialHeight) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          } else {
            _scrollController.jumpTo(_initialHeight);
          }
        }
      });
    }
  }

  List<Widget> _addCommentWidgets(List<Widget> listOfWidgets) {
    //TODO new comment textbox / respective API calling

    listOfWidgets.add(
      Divider(
        height: 10.0,
        color: Colors.transparent,
      ),
    );

    listOfWidgets.addAll(_comments.map(
      (comment) => CommentTile(
            comment: comment,
          ),
    ));

    return listOfWidgets;
  }
}
