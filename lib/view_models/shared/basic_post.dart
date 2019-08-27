import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/enums/change_vote_action.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

enum BasicPostViewState { Inactive, UpVote, DownVote, NoVote }

class BasicPostModel extends StateModel<BasicPostViewState> {
  BasicPostModel() : super(BasicPostViewState.Inactive);

  final _repository = locator<Repository>();
  final _appInfo = locator<AppInfo>();
  final _lock = Lock();
  Post _post;

  // * Init Functions
  void init(Post post) {
    setPost(post);
  }

  /////////////////////////////////////////////////////////////
  // * Setters
  void setPost(Post post) {
    _post = post;
    switch (post.userVote) {
      case 0:
        setState(BasicPostViewState.NoVote);
        break;
      case -1:
        setState(BasicPostViewState.DownVote);
        break;
      case 1:
        setState(BasicPostViewState.UpVote);
    }
  }

  /////////////////////////////////////////////////////////////
  // * Navigator Functions
  void navigateToDetailedPost(BuildContext context, bool toComments) async {
    Navigator.of(context).pushNamed(
      RouteName.detailedPost,
      arguments: {
        'toComments': toComments,
        'basicPostModel': this,
      },
    );
  }

  void navigateToUserProfile(BuildContext context) {
    // TODO navigateToUserProfile
    Navigator.of(context).pushNamed(
      RouteName.userProfile,
      arguments: _post.user.id,
    );
  }

  Future<String> navigateToCollectionList(BuildContext context) async {
    // TODO navigateToCollections?
    return await Navigator.of(context).pushNamed(
      RouteName.collectionList,
      arguments: {
        'isAddToCollection': true,
        'postId': _post.id,
      },
    );
  }

  /////////////////////////////////////////////////////////////
  // * on__ Functions
  Future onUpvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_post.userVote == 1) {
        _post.votes--;
        setState(BasicPostViewState.NoVote);

        int result = await _repository.changeVote(
          _post.id,
          ChangeVoteAction.Remove,
        );

        if (result == 0) {
          _post.userVote = 0;
        } else {
          _post.votes++;
          setState(BasicPostViewState.UpVote);
          // TODO place dialog here?
        }
        return;
      }

      bool existsVote = _post.userVote == -1;
      existsVote ? _post.votes += 2 : _post.votes++;

      setState(BasicPostViewState.UpVote);

      int result = await _repository.changeVote(
        _post.id,
        ChangeVoteAction.Up,
      );

      if (result == 0) {
        _post.userVote = 1;
      } else {
        if (existsVote) {
          _post.votes -= 2;
          setState(BasicPostViewState.DownVote);
          return;
        }

        _post.votes--;
        setState(BasicPostViewState.NoVote);
        // TODO place dialog here?
      }
    });
  }

  Future onDownvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_post.userVote == -1) {
        _post.votes++;
        setState(BasicPostViewState.NoVote);

        int result = await _repository.changeVote(
          _post.id,
          ChangeVoteAction.Remove,
        );

        if (result == 0) {
          _post.userVote = 0;
        } else {
          _post.votes--;
          setState(BasicPostViewState.DownVote);
          // TODO place dialog here
        }
        return;
      }

      bool existsVote = _post.userVote == 1;
      existsVote ? _post.votes -= 2 : _post.votes--;

      setState(BasicPostViewState.DownVote);

      int result = await _repository.changeVote(
        _post.id,
        ChangeVoteAction.Down,
      );

      if (result == 0) {
        _post.userVote = -1;
      } else {
        if (existsVote) {
          _post.votes += 2;
          setState(BasicPostViewState.UpVote);
          return;
        }

        _post.votes++;
        setState(BasicPostViewState.NoVote);
      }
    });
  }

  Future<void> onSelected(BuildContext context, int value) async {
    if (value == 1) {
      String collectionName = await navigateToCollectionList(context);

      if (collectionName != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add to collection'),
              content: Text('Post has been added to $collectionName'),
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
  }

  Post get post => _post;
  bool get isSelf => _appInfo.currentUser.id == _post.user.id;
}
