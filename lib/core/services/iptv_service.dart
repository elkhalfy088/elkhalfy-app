import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'dart:convert';
import '../../data/models/channel_model.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/series_model.dart';

enum IPTVSourceType { xtream, mac, m3u8 }

class IPTVSource {
  final String id;
  final String name;
  final IPTVSourceType type;
  final String serverUrl;
  final String username;
  final String password;
  final String portalUrl;
  final String macAddress;
  final String m3uUrl;
  final bool showChannels;
  final bool showMovies;
  final bool showSeries;
  final String? activationCode;
  final bool visible;
  final int order;

  IPTVSource({
    required this.id,
    required this.name,
    required this.type,
    this.serverUrl = '',
    this.username = '',
    this.password = '',
    this.portalUrl = '',
    this.macAddress = '',
    this.m3uUrl = '',
    this.showChannels = true,
    this.showMovies = true,
    this.showSeries = true,
    this.activationCode,
    this.visible = true,
    this.order = 0,
  });

  factory IPTVSource.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] ?? 'xtream';
    IPTVSourceType type;
    switch (typeStr) {
      case 'mac':
        type = IPTVSourceType.mac;
        break;
      case 'm3u8':
        type = IPTVSourceType.m3u8;
        break;
      default:
        type = IPTVSourceType.xtream;
    }

    return IPTVSource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: type,
      serverUrl: map['server_url'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      portalUrl: map['portal_url'] ?? '',
      macAddress: map['mac_address'] ?? '',
      m3uUrl: map['m3u_url'] ?? '',
      showChannels: map['show_channels'] ?? true,
      showMovies: map['show_movies'] ?? true,
      showSeries: map['show_series'] ?? true,
      activationCode: map['activation_code'],
      visible: map['visible'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  String get apiBase => '$serverUrl/player_api.php?username=$username&password=$password';
}

class IPTVService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Xtream Codes - Get live channels
  Future<List<ChannelModel>> getLiveChannels(IPTVSource source) async {
    try {
      final response = await _dio.get(
        '${source.apiBase}&action=get_live_streams',
      );

      if (response.data is List) {
        return (response.data as List)
            .map((item) => ChannelModel.fromXtream(
                  Map<String, dynamic>.from(item),
                  source.serverUrl,
                  source.username,
                  source.password,
                ))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Xtream Codes - Get live categories
  Future<List<Map<String, dynamic>>> getLiveCategories(IPTVSource source) async {
    try {
      final response = await _dio.get(
        '${source.apiBase}&action=get_live_categories',
      );
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(
          (response.data as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Xtream Codes - Get VOD (movies)
  Future<List<MovieModel>> getMovies(IPTVSource source) async {
    try {
      final response = await _dio.get(
        '${source.apiBase}&action=get_vod_streams',
      );
      if (response.data is List) {
        return (response.data as List)
            .map((item) => MovieModel.fromXtream(Map<String, dynamic>.from(item), source.serverUrl, source.username, source.password))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Xtream Codes - Get VOD categories
  Future<List<Map<String, dynamic>>> getVodCategories(IPTVSource source) async {
    try {
      final response = await _dio.get(
        '${source.apiBase}&action=get_vod_categories',
      );
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(
          (response.data as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Xtream Codes - Get Series
  Future<List<SeriesModel>> getSeries(IPTVSource source) async {
    try {
      final response = await _dio.get(
        '${source.apiBase}&action=get_series',
      );
      if (response.data is List) {
        return (response.data as List)
            .map((item) => SeriesModel.fromXtream(Map<String, dynamic>.from(item), source.serverUrl, source.username, source.password))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Xtream Codes - Get Series episodes
  Future<Map<String, dynamic>?> getSeriesInfo(IPTVSource source, String seriesId) async {
    try {
      final response = await _dio.get(
        '${source.apiBase}&action=get_series_info&series_id=$seriesId',
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // M3U8 - Parse M3U file
  Future<List<ChannelModel>> parseM3U(String url) async {
    try {
      final response = await _dio.get(url);
      final String content = response.data.toString();
      return _parseM3UContent(content);
    } catch (e) {
      return [];
    }
  }

  List<ChannelModel> _parseM3UContent(String content) {
    final List<ChannelModel> channels = [];
    final lines = content.split('\n');

    String? name, logo, group, url;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTINF:')) {
        // Parse channel info
        final nameMatch = RegExp(r',(.+)$').firstMatch(line);
        final logoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);
        final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(line);

        name = nameMatch?.group(1)?.trim();
        logo = logoMatch?.group(1);
        group = groupMatch?.group(1);
      } else if (line.isNotEmpty && !line.startsWith('#') && name != null) {
        url = line;
        channels.add(ChannelModel(
          id: url.hashCode.toString(),
          name: name,
          streamUrl: url,
          logo: logo ?? '',
          categoryName: group ?? 'عام',
          categoryId: '',
          epg: '',
          isLive: true,
        ));
        name = null;
        logo = null;
        group = null;
        url = null;
      }
    }

    return channels;
  }

  // Build stream URL for Xtream
  String buildLiveStreamUrl(IPTVSource source, String streamId) {
    return '${source.serverUrl}/live/${source.username}/${source.password}/$streamId.ts';
  }

  String buildMovieStreamUrl(IPTVSource source, String streamId, String ext) {
    return '${source.serverUrl}/movie/${source.username}/${source.password}/$streamId.$ext';
  }

  String buildEpisodeStreamUrl(IPTVSource source, String streamId, String ext) {
    return '${source.serverUrl}/series/${source.username}/${source.password}/$streamId.$ext';
  }
}
