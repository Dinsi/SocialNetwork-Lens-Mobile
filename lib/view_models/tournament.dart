import 'package:aperture/locator.dart';
import 'package:aperture/models/tournament_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/base_model.dart';

enum TournamentViewState { Active, Inactive, Loading }

class TournamentModel extends StateModel<TournamentViewState> {
  final _repository = locator<Repository>();
  TournamentInfo _tournamentInfo;

  TournamentModel() : super(TournamentViewState.Loading);

  Future<void> init() async {
    _tournamentInfo = await _repository.fetchTournamentInfo();
    setState(_tournamentInfo.currentStage == null
        ? TournamentViewState.Inactive
        : TournamentViewState.Active);
  }
}
