import 'package:aperture/models/comment.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/ui/shared/comment_tile.dart';
import 'package:aperture/ui/shared/description_text_widget.dart';
import 'package:aperture/ui/shared/image_container.dart';
import 'package:aperture/utils/post_shared_functions.dart';
import 'package:aperture/view_models/post_details_bloc.dart';
import 'package:aperture/view_models/providers/post_details_bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:synchronized/synchronized.dart';
import 'package:transparent_image/transparent_image.dart';

const double _votesTabHeight = 55.0;
const double _iconSideSize = 60.0;
const double _defaultHeight = 75.0;
const double _heightOfInitialCircularIndicator = 100.0;

class DetailedPostScreen extends StatefulWidget {
  final Post post;
  final bool toComments;

  const DetailedPostScreen({@required this.post, @required this.toComments});

  @override
  _DetailedPostScreenState createState() => _DetailedPostScreenState(this.post);
}

class _DetailedPostScreenState extends State<DetailedPostScreen> {
  _DetailedPostScreenState(this._post);

  GlobalKey _columnKey = GlobalKey();
  Post _post;
  bool _downIconColor;
  bool _upIconColor;
  ScrollController _scrollController;
  final Lock _lock = Lock();
  double _initialHeight;
  VoidCallback _onPressedButtonFunction;
  TextEditingController _commentController;
  FocusNode _commentNode;

  bool _enabledBackButton;

  PostDetailsBloc bloc;
  bool _isInit;

  @override
  void initState() {
    super.initState();

    _enabledBackButton = true;

    _scrollController = ScrollController();
    _commentController = TextEditingController();
    _commentNode = FocusNode();
    _commentController.addListener(_checkButtonStatus);

    _setIconColors();

    if (widget.toComments) {
      WidgetsBinding.instance.addPostFrameCallback(_getInitialHeight);
    }

    _isInit = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit && mounted) {
      bloc = PostDetailsBlocProvider.of(context);
      bloc.fetchComments().then((_) {
        _scrollController.addListener(() {
          if (_scrollController.offset ==
                  _scrollController.position.maxScrollExtent &&
              bloc.existsNext) {
            bloc.fetchComments();
          }
        });

        if (bloc.hasComments && widget.toComments) {
          if (_scrollController.position.maxScrollExtent <= _initialHeight) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          } else {
            _scrollController.jumpTo(_initialHeight);
          }
        }
      });

      _isInit = false;
    }
  }

  void _getInitialHeight(_) {
    final RenderBox renderBoxColumn =
        _columnKey.currentContext.findRenderObject();
    _initialHeight =
        renderBoxColumn.size.height - _heightOfInitialCircularIndicator;
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _commentNode.dispose();
    _commentController.removeListener(_checkButtonStatus);
    _commentController.dispose();
    bloc.dispose();
    super.dispose();
  }

  Future _onRefresh() async {
    Post updatedPost = await bloc.clearAndFetch();
    setState(() => _post = updatedPost);
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
                    onTap: () => Navigator.of(context)
                        .pushNamed('/userProfile', arguments: {
                      'id': widget.post.user.id,
                      'username': widget.post.user.username,
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(
            _post.user.name,
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

    var descriptionText = DescriptionTextWidget(
      text: _post.description,
      withHashtags: true,
    );

    var imageContainer = ImageContainer(
      imageUrl: _post.image,
      imageHeight: _post.height,
      imageWidth: _post.width,
      onTap: /*TODO _toFullImageScreen*/ null,
      onDoubleTap: () => _upvoteOrRemove(),
    );

    var votesTab = Material(
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
              Material(
                child: InkWell(
                  onTap: () {},
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
                onSelected: (int value) async {
                  if (value == 1) {
                    String collectionName =
                        await Navigator.of(context).pushNamed(
                      '/collectionList',
                      arguments: {
                        'addToCollection': true,
                        'postId': widget.post.id,
                      },
                    );

                    if (collectionName != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Add to collection'),
                            content:
                                Text('Post has been added to $collectionName'),
                            actions: <Widget>[
                              FlatButton(
                                child: const Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            ],
                          );
                        },
                      );
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
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
    );

    var comments = StreamBuilder<List<Comment>>(
      stream: bloc.comments,
      builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
        SizedBox sizedIndicator = SizedBox(
          height: _heightOfInitialCircularIndicator,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
            ),
          ),
        );

        if (snapshot.hasData) {
          Column commentsColumn = Column(children: <Widget>[]);

          snapshot.data.forEach((comment) =>
              commentsColumn.children.add(CommentTile(comment: comment)));

          if (bloc.existsNext) {
            commentsColumn.children.add(sizedIndicator);
          }

          return commentsColumn;
        }

        return sizedIndicator;
      },
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
      comments
    ];

    var newCommentContainer = Container(
      child: Column(
        children: <Widget>[
          Divider(height: 10.0, color: Colors.black45),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 9.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentNode,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1024),
                    ],
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 2.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    width: 100.0,
                    child: FlatButton(
                      child: Text(
                        'Publish',
                        style: TextStyle(
                          fontSize: 19.0,
                          color: _onPressedButtonFunction != null
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                      onPressed: _onPressedButtonFunction,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () {
        if (_enabledBackButton) {
          Navigator.of(context).pop({
            'post': _post,
            'upIconColor': _upIconColor,
            'downIconColor': _downIconColor,
          });
        }

        return Future<bool>.value(false);
      },
      child: Scaffold(
        body: SafeArea(
          child: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: Theme.of(context).iconTheme.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        key: _columnKey,
                        children: listOfWidgets,
                      ),
                    ),
                  ),
                  newCommentContainer,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _downvoteOrRemove() async {
    await _lock.synchronized(() async {
      _enabledBackButton = false;
      if (_post.userVote == -1) {
        setState(() {
          _downIconColor = false;
          _post.votes++;
        });

        int result = await bloc.removeVote();

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
        _enabledBackButton = true;
        return;
      }

      setState(() {
        _upIconColor = false;
        _downIconColor = true;
        _post.userVote == 1 ? _post.votes -= 2 : _post.votes--;
      });

      int result = await bloc.downVote();

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
      _enabledBackButton = true;
    });
  }

  Future _upvoteOrRemove() async {
    await _lock.synchronized(() async {
      _enabledBackButton = false;
      if (_post.userVote == 1) {
        setState(() {
          _upIconColor = false;
          _post.votes--;
        });

        int result = await bloc.removeVote();

        if (result == 0) {
          setState(() {
            _post.userVote = 0;
          });
        } else {
          setState(() {
            _upIconColor = true;
            _post.votes++;
          });
          /*TODO place dialog here*/
        }

        _enabledBackButton = true;
        return;
      }

      setState(() {
        _upIconColor = true;
        _downIconColor = false;
        _post.userVote == -1 ? _post.votes += 2 : _post.votes++;
      });

      int result = await bloc.upVote();

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

      _enabledBackButton = true;
    });
  }

  void _checkButtonStatus() {
    String trimmedComment = _commentController.text.trim();
    if (trimmedComment.isEmpty) {
      if (_onPressedButtonFunction != null) {
        setState(() => _onPressedButtonFunction = null);
      }
    } else {
      if (_onPressedButtonFunction == null) {
        setState(() => _onPressedButtonFunction = _onPressed);
      }
    }
  }

  Future _onPressed() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    String comment = _commentController.text.trim();
    _commentController.clear();

    await bloc.postComment(comment); // TODO assuming result is valid

    if (mounted) {
      setState(() {
        _post.commentsLength++;
      });
    }
  }
}
