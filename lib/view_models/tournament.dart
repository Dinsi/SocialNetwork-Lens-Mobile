import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/models/tournament_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/enums/change_vote_action.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';

const _backendListSize = 5;

enum TournamentViewState { ActivePhase1, ActivePhase2, Inactive, Loading }

class TournamentModel extends StateModel<TournamentViewState> {
  final _repository = locator<Repository>();
  TournamentInfo _tournamentInfo;
  List<Post> _tournamentPosts;

  // Phase 1
  int _currentIndex;
  bool existsNext;

  TournamentModel() : super(TournamentViewState.Loading);

  Future<void> init() async {
    _tournamentInfo = await _repository.fetchTournamentInfo();

    switch (_tournamentInfo.currentStage) {
      case 1:
        _tournamentPosts = await _repository.fetchTournamentPosts();

        if (_tournamentPosts.isNotEmpty) {
          _currentIndex = 0;
          existsNext = _tournamentPosts.length == _backendListSize;
          debugPrint(_tournamentPosts[_currentIndex].image);
        }

        setState(TournamentViewState.ActivePhase1);
        break;

      case 2:
        _tournamentPosts = await _repository.fetchTournamentPosts();

        setState(TournamentViewState.ActivePhase2);
        break;

      default:
        setState(TournamentViewState.Inactive);
    }
  }

  Future<void> changeVotePh1(
      BuildContext context, ChangeVoteAction action) async {
    final targetIndex = _currentIndex;
    _repository.changeVote(_tournamentPosts[targetIndex].id, action);

    if (_tournamentPosts.length > _currentIndex + 1) {
      _currentIndex++;
      notifyListeners();
      
      debugPrint(_tournamentPosts[_currentIndex].image);
    } else {
      if (existsNext) {
        _currentIndex = -1;
        notifyListeners();

        _tournamentPosts = await _repository.fetchTournamentPosts();

        if (_tournamentPosts.isNotEmpty) {
          _currentIndex = 0;
          debugPrint(_tournamentPosts[_currentIndex].image);
          return;
        }
      }

      _currentIndex = null;
      notifyListeners();
    }
  }

  Future<void> changeVotePh2(BuildContext context, int index) async {
    final theme = Theme.of(context);
    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: theme.copyWith(primaryColor: Colors.red),
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Are you sure you want to vote on this post?\n'),
              Text(
                'This action is irreversible for the current tournament',
                style: theme.textTheme.subtitle.copyWith(
                  color: Colors.grey,
                ),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop<bool>(false),
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop<bool>(true),
            )
          ],
        ),
      ),
    );

    if (dialogResult != true) {
      return;
    }

    _tournamentInfo.votedPostId = _tournamentPosts[index].id;
    notifyListeners();

    try {
      await _repository
          .submitVoteToCurrentTournament(_tournamentPosts[index].id);
    } on Exception {
      _tournamentInfo.votedPostId = null;
      notifyListeners();
    }
  }

  // * Navigation
  void navigateToDetailedPost(BuildContext context, int index) {
    final model = locator<BasicPostModel>();
    model.init(_tournamentPosts[index]);
    Navigator.of(context).pushNamed(RouteName.detailedPost, arguments: model);
  }

  // * Getters
  String get tournamentName => _tournamentInfo.title;
  bool get userHasVoted => _tournamentInfo.votedPostId != null;
  bool isVotedPost(int index) =>
      _tournamentInfo.votedPostId == _tournamentPosts[index].id;

  bool get noPostExists => _tournamentPosts?.isEmpty ?? true;
  int get listLength => _tournamentPosts.length;
  Post get currentPost => _tournamentPosts[_currentIndex];
  Post getPostByIndex(int index) => _tournamentPosts[index];
  int get currentIndex => _currentIndex;
}
