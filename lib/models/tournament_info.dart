class TournamentInfo {
  final int id;
  final String title;
  final String description;
  final int currentStage;
  final DateTime startDate;
  final DateTime nextStageDate;
  final DateTime endDate;
  int votedPostId;

  TournamentInfo(this.id, this.title, this.description, this.currentStage,
      this.startDate, this.nextStageDate, this.endDate, this.votedPostId);

  factory TournamentInfo.fromJson(Map<String, dynamic> json) {
    return TournamentInfo(
      json['id'],
      json['title'],
      json['description'],
      json['current_stage'],
      DateTime.parse(json['start_date']),
      DateTime.parse(json['next_stage_date']),
      DateTime.parse(json['end_date']),
      json['???'], // TODO fill with aproppriate field when available
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['current_stage'] = this.currentStage;
    data['start_date'] = this.startDate.toString();
    data['next_stage_date'] = this.nextStageDate.toString();
    data['end_date'] = this.endDate.toString();
    data['???'] = this.votedPostId;
    return data;
  }
}
