class MovieModel {
  final String id;
  final String name;
  final String coverUrl;
  final String plot;
  final String rating;
  final String releaseDate;
  final String duration;
  final String categoryId;
  final String categoryName;
  final String streamUrl;
  final String containerExtension;
  final String director;
  final String cast;
  final String genre;
  final String youtubeTrailer;

  MovieModel({
    required this.id,
    required this.name,
    required this.coverUrl,
    this.plot = '',
    this.rating = '',
    this.releaseDate = '',
    this.duration = '',
    required this.categoryId,
    required this.categoryName,
    required this.streamUrl,
    this.containerExtension = 'mp4',
    this.director = '',
    this.cast = '',
    this.genre = '',
    this.youtubeTrailer = '',
  });

  factory MovieModel.fromXtream(
    Map<String, dynamic> map,
    String serverUrl,
    String username,
    String password,
  ) {
    final streamId = map['stream_id']?.toString() ?? '';
    final ext = map['container_extension'] ?? 'mp4';
    final streamUrl = '$serverUrl/movie/$username/$password/$streamId.$ext';

    return MovieModel(
      id: streamId,
      name: map['name'] ?? '',
      coverUrl: map['stream_icon'] ?? map['cover'] ?? '',
      plot: map['plot'] ?? '',
      rating: map['rating']?.toString() ?? '',
      releaseDate: map['releaseDate'] ?? map['release_date'] ?? '',
      duration: map['duration'] ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name'] ?? '',
      streamUrl: streamUrl,
      containerExtension: ext,
      director: map['director'] ?? '',
      cast: map['cast'] ?? '',
      genre: map['genre'] ?? '',
      youtubeTrailer: map['youtube_trailer'] ?? '',
    );
  }
}
