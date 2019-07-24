import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/base_model.dart';
import 'package:synchronized/synchronized.dart';

enum BasicPostViewState { UpVote, DownVote, NoVote }

class BasicPostModel extends StateModel<BasicPostViewState> {
  final Repository _repository = locator<Repository>();
  final Lock _lock = Lock();
  Post _post;

  BasicPostModel() : super(null);

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

  /*Future toDetailedPostScreen(bool toComments) async {
    Map<String, dynamic> result = await Navigator.of(context)
        .pushNamed('/detailedPost', arguments: {
      'postId': _post.id,
      'post': _post,
      'toComments': toComments
    });

    setPost(result['post']);
  }*/

  Future downvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_post.userVote == -1) {
        _post.votes++;
        setState(BasicPostViewState.NoVote);

        int result = await _repository.changeVote(_post.id, "removevote");

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

      int result = await _repository.changeVote(_post.id, "downvote");

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

  Future upvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_post.userVote == 1) {
        _post.votes--;
        setState(BasicPostViewState.NoVote);

        int result = await _repository.changeVote(_post.id, "removevote");

        if (result == 0) {
          _post.userVote = 0;
        } else {
          _post.votes++;
          setState(BasicPostViewState.UpVote);
          // TODO place dialog here
        }
        return;
      }

      bool existsVote = _post.userVote == -1;
      existsVote ? _post.votes += 2 : _post.votes++;

      setState(BasicPostViewState.UpVote);

      int result = await _repository.changeVote(_post.id, "upvote");

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
        // TODO place dialog here
      }
    });
  }

  Post get post => _post;
}
