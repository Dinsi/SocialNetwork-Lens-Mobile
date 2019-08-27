import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/models/tournament_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/enums/change_vote_action.dart';
import 'package:flutter/material.dart';

enum TournamentViewState { Active, Inactive, Loading }

class TournamentModel extends StateModel<TournamentViewState> {
  final _repository = locator<Repository>();
  TournamentInfo _tournamentInfo;
  List<Post> _tournamentPosts;
  int _currentIndex;

  TournamentModel() : super(TournamentViewState.Loading);

  Future<void> init() async {
    _tournamentInfo = await _repository.fetchTournamentInfo();
    if (_tournamentInfo.currentStage == null) {
      setState(TournamentViewState.Inactive);
    } else {
      _tournamentPosts = await _repository.fetchTournamentPosts();
      if (_tournamentPosts.isNotEmpty) {
        _currentIndex = 0;
      }
      setState(TournamentViewState.Active);
    }
  }

  Future<void> changeVote(BuildContext context, ChangeVoteAction action) async {
    final targetIndex = _currentIndex;
    _repository.changeVote(_tournamentPosts[targetIndex].id, action);

    if (_tournamentPosts.length > _currentIndex + 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      _currentIndex = null;

      setState(TournamentViewState.Loading);

      _tournamentPosts = await _repository.fetchTournamentPosts();
      if (_tournamentPosts.isNotEmpty) {
        _currentIndex = 0;
      }

      setState(TournamentViewState.Active);
    }
  }

  bool get noPostExists => _tournamentPosts.isEmpty;
  Post get currentPost => _tournamentPosts[_currentIndex];
  int get currentIndex => _currentIndex;
}
