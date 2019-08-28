import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/models/tournament_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/enums/change_vote_action.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';

enum TournamentViewState { ActivePhase1, ActivePhase2, Inactive, Loading }

class TournamentModel extends StateModel<TournamentViewState> {
  final _repository = locator<Repository>();
  TournamentInfo _tournamentInfo;
  List<Post> _tournamentPosts;

  // Phase 1
  int _currentIndex;

  // Phase 2
  List<BasicPostModel> _basicPostModels;

  TournamentModel() : super(TournamentViewState.Loading);

  Future<void> init() async {
    _tournamentInfo = await _repository.fetchTournamentInfo();

    switch (_tournamentInfo.currentStage) {
      case 1:
        _tournamentPosts = await _repository.fetchTournamentPosts();
        if (_tournamentPosts.isNotEmpty) {
          _currentIndex = 0;
          print(_tournamentPosts[_currentIndex].image);
        }
        setState(TournamentViewState.ActivePhase1);
        break;

      case 2:
        _tournamentPosts = await _repository.fetchTournamentPosts();
        _basicPostModels = List.generate(
          _tournamentPosts.length,
          (index) => locator<BasicPostModel>()..init(_tournamentPosts[index]),
          growable: false,
        );

        setState(TournamentViewState.ActivePhase2);
        break;

      default:
        setState(TournamentViewState.Inactive);
    }
  }

  Future<void> changeVotePh1(BuildContext context, ChangeVoteAction action) async {
    final targetIndex = _currentIndex;
    _repository.changeVote(_tournamentPosts[targetIndex].id, action);

    if (_tournamentPosts.length > _currentIndex + 1) {
      _currentIndex++;
      print(_tournamentPosts[_currentIndex].image);

      notifyListeners();
    } else {
      _currentIndex = -1;
      notifyListeners();

      _tournamentPosts = await _repository.fetchTournamentPosts();
      if (_tournamentPosts.isNotEmpty) {
        _currentIndex = 0;
        print(_tournamentPosts[_currentIndex].image);
      }

      notifyListeners();
    }
  }

  void changeVotePh2(int index) => _basicPostModels[index].onUpvoteOrRemove();

  // * Getters
  String get tournamentName => _tournamentInfo.title;

  BasicPostModel getBasicPostModel(int index) => _basicPostModels[index];

  bool get noPostExists => _tournamentPosts?.isEmpty ?? true;
  int get listLength => _tournamentPosts.length;
  Post get currentPost => _tournamentPosts[_currentIndex];
  Post getPostByIndex(int index) => _tournamentPosts[index];
  int get currentIndex => _currentIndex;
}
