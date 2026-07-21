class SeriesModel {
  final String id;
  final String name;
  final String coverUrl;
  final String plot;
  final String rating;
  final String releaseDate;
  final String categoryId;
  final String categoryName;
  final String cast;
  final String director;
  final String genre;
  final String serverUrl;
  final String username;
  final String password;

  SeriesModel({
    required this.id,
    required this.name,
    required this.coverUrl,
    this.plot = '',
    this.rating = '',
    this.releaseDate = '',
    required this.categoryId,
    required this.categoryName,
    this.cast = '',
    this.director = '',
    this.genre = '',
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  factory SeriesModel.fromXtream(
    Map<String, dynamic> map,
    String serverUrl,
    String username,
    String password,
  ) {
    return SeriesModel(
      id: map['series_id']?.toString() ?? '',
      name: map['name'] ?? '',
      coverUrl: map['cover'] ?? '',
      plot: map['plot'] ?? '',
      rating: map['rating']?.toString() ?? '',
      releaseDate: map['releaseDate'] ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name'] ?? '',
      cast: map['cast'] ?? '',
      director: map['director'] ?? '',
      genre: map['genre'] ?? '',
      serverUrl: serverUrl,
      username: username,
      password: password,
    );
  }
}

class SeasonModel {
  final String seasonNumber;
  final List<EpisodeModel> episodes;

  SeasonModel({
    required this.seasonNumber,
    required this.episodes,
  });
}

class EpisodeModel {
  final String id;
  final String title;
  final String episodeNum;
  final String season;
  final String containerExtension;
  final String coverUrl;
  final String plot;
  final String duration;
  final String releaseDate;
  final String streamUrl;

  EpisodeModel({
    required this.id,
    required this.title,
    required this.episodeNum,
    required this.season,
    required this.containerExtension,
    this.coverUrl = '',
    this.plot = '',
    this.duration = '',
    this.releaseDate = '',
    required this.streamUrl,
  });

  factory EpisodeModel.fromMap(
    Map<String, dynamic> map,
    String serverUrl,
    String username,
    String password,
  ) {
    final episodeId = map['id']?.toString() ?? '';
    final ext = map['container_extension'] ?? 'mp4';
    final streamUrl = '$serverUrl/series/$username/$password/$episodeId.$ext';

    return EpisodeModel(
      id: episodeId,
      title: map['title'] ?? '',
      episodeNum: map['episode_num']?.toString() ?? '',
      season: map['season']?.toString() ?? '',
      containerExtension: ext,
      coverUrl: map['info']?['movie_image'] ?? '',
      plot: map['info']?['plot'] ?? '',
      duration: map['info']?['duration'] ?? '',
      releaseDate: map['info']?['releasedate'] ?? '',
      streamUrl: streamUrl,
    );
  }
}
