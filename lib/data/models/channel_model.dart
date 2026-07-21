class ChannelModel {
  final String id;
  final String name;
  final String streamUrl;
  final String logo;
  final String categoryId;
  final String categoryName;
  final String epg;
  final bool isLive;
  final int? num;

  ChannelModel({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.logo,
    required this.categoryId,
    required this.categoryName,
    required this.epg,
    required this.isLive,
    this.num,
  });

  factory ChannelModel.fromXtream(
    Map<String, dynamic> map,
    String serverUrl,
    String username,
    String password,
  ) {
    final streamId = map['stream_id']?.toString() ?? '';
    final streamUrl = '$serverUrl/live/$username/$password/$streamId.ts';

    return ChannelModel(
      id: streamId,
      name: map['name'] ?? '',
      streamUrl: streamUrl,
      logo: map['stream_icon'] ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name'] ?? '',
      epg: map['epg_channel_id'] ?? '',
      isLive: true,
      num: map['num'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'streamUrl': streamUrl,
    'logo': logo,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'epg': epg,
    'isLive': isLive,
    'num': num,
  };
}
