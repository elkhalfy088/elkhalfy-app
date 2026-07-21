enum MatchStatus { upcoming, live, finished }

class MatchModel {
  final String id;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final String homeScore;
  final String awayScore;
  final String matchTime;
  final String matchDate;
  final String leagueName;
  final String leagueLogo;
  final MatchStatus status;
  final List<GoalEvent> goals;
  final List<CardEvent> cards;
  final List<SubstitutionEvent> substitutions;
  final MatchStats? stats;

  MatchModel({
    required this.id,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeTeamLogo = '',
    this.awayTeamLogo = '',
    this.homeScore = '',
    this.awayScore = '',
    this.matchTime = '',
    this.matchDate = '',
    this.leagueName = '',
    this.leagueLogo = '',
    required this.status,
    this.goals = const [],
    this.cards = const [],
    this.substitutions = const [],
    this.stats,
  });

  factory MatchModel.fromDynamic(
    Map<String, dynamic> map,
    Map<String, dynamic> fieldMapping,
  ) {
    String _getValue(String fieldName) {
      if (fieldName.isEmpty) return '';
      final parts = fieldName.split('.');
      dynamic current = map;
      for (final part in parts) {
        if (current is Map) {
          current = current[part];
        } else {
          return '';
        }
      }
      return current?.toString() ?? '';
    }

    final statusStr = _getValue(fieldMapping['status'] ?? 'status').toLowerCase();
    MatchStatus status;
    if (statusStr.contains('live') || statusStr.contains('progress') || statusStr.contains('1h') || statusStr.contains('2h')) {
      status = MatchStatus.live;
    } else if (statusStr.contains('ft') || statusStr.contains('finished') || statusStr.contains('end')) {
      status = MatchStatus.finished;
    } else {
      status = MatchStatus.upcoming;
    }

    return MatchModel(
      id: map['id']?.toString() ?? map.hashCode.toString(),
      homeTeamName: _getValue(fieldMapping['home_team'] ?? 'homeTeam.name'),
      awayTeamName: _getValue(fieldMapping['away_team'] ?? 'awayTeam.name'),
      homeTeamLogo: _getValue(fieldMapping['home_logo'] ?? 'homeTeam.logo'),
      awayTeamLogo: _getValue(fieldMapping['away_logo'] ?? 'awayTeam.logo'),
      homeScore: _getValue(fieldMapping['home_score'] ?? 'goals.home'),
      awayScore: _getValue(fieldMapping['away_score'] ?? 'goals.away'),
      matchTime: _getValue(fieldMapping['time'] ?? 'fixture.date'),
      matchDate: _getValue(fieldMapping['date'] ?? 'fixture.date'),
      leagueName: _getValue(fieldMapping['league_name'] ?? 'league.name'),
      leagueLogo: _getValue(fieldMapping['league_logo'] ?? 'league.logo'),
      status: status,
    );
  }
}

class GoalEvent {
  final String playerName;
  final String minute;
  final String team;

  GoalEvent({required this.playerName, required this.minute, required this.team});
}

class CardEvent {
  final String playerName;
  final String minute;
  final String type; // yellow, red
  final String team;

  CardEvent({required this.playerName, required this.minute, required this.type, required this.team});
}

class SubstitutionEvent {
  final String playerIn;
  final String playerOut;
  final String minute;
  final String team;

  SubstitutionEvent({required this.playerIn, required this.playerOut, required this.minute, required this.team});
}

class MatchStats {
  final String homePossession;
  final String awayPossession;
  final String homeShots;
  final String awayShots;
  final String homeShotsOnTarget;
  final String awayShotsOnTarget;
  final String homeCorners;
  final String awayCorners;
  final String homeFouls;
  final String awayFouls;

  MatchStats({
    this.homePossession = '',
    this.awayPossession = '',
    this.homeShots = '',
    this.awayShots = '',
    this.homeShotsOnTarget = '',
    this.awayShotsOnTarget = '',
    this.homeCorners = '',
    this.awayCorners = '',
    this.homeFouls = '',
    this.awayFouls = '',
  });
}
