import 'package:get/get.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/activation/activation_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/live_tv/live_tv_screen.dart';
import '../presentation/movies/movies_screen.dart';
import '../presentation/movies/movie_detail_screen.dart';
import '../presentation/series/series_screen.dart';
import '../presentation/series/series_detail_screen.dart';
import '../presentation/news/news_screen.dart';
import '../presentation/news/news_detail_screen.dart';
import '../presentation/matches/matches_screen.dart';
import '../presentation/matches/match_detail_screen.dart';
import '../presentation/player/player_screen.dart';
import '../presentation/downloads/downloads_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/maintenance/maintenance_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String activation = '/activation';
  static const String home = '/home';
  static const String liveTV = '/live-tv';
  static const String movies = '/movies';
  static const String movieDetail = '/movie-detail';
  static const String series = '/series';
  static const String seriesDetail = '/series-detail';
  static const String news = '/news';
  static const String newsDetail = '/news-detail';
  static const String matches = '/matches';
  static const String matchDetail = '/match-detail';
  static const String player = '/player';
  static const String downloads = '/downloads';
  static const String settings = '/settings';
  static const String maintenance = '/maintenance';

  static List<GetPage> get pages => [
        GetPage(
          name: splash,
          page: () => const SplashScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: activation,
          page: () => const ActivationScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: home,
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: liveTV,
          page: () => const LiveTvScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: movies,
          page: () => const MoviesScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: movieDetail,
          page: () => const MovieDetailScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: series,
          page: () => const SeriesScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: seriesDetail,
          page: () => const SeriesDetailScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: news,
          page: () => const NewsScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: newsDetail,
          page: () => const NewsDetailScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: matches,
          page: () => const MatchesScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: matchDetail,
          page: () => const MatchDetailScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: player,
          page: () => const PlayerScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: downloads,
          page: () => const DownloadsScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: settings,
          page: () => const SettingsScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: maintenance,
          page: () => const MaintenanceScreen(),
          transition: Transition.fadeIn,
        ),
      ];
}
