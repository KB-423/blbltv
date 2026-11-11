import 'package:flutter/material.dart';

/// 细分频道（子分区）数据模型
class SubChannel {
  final String name;
  final int rid;

  const SubChannel({
    required this.name,
    required this.rid,
  });
}

/// 一级主频道数据模型
class MainChannel {
  final String name;
  final int rid;
  final IconData icon;
  final List<SubChannel> subChannels;

  const MainChannel({
    required this.name,
    required this.rid,
    required this.icon,
    required this.subChannels,
  });

  /// 官方标准主频道与细分频道体系
  static const List<MainChannel> defaultChannels = [
    MainChannel(
      name: '游戏',
      rid: 4,
      icon: Icons.sports_esports_rounded,
      subChannels: [
        SubChannel(name: '全部游戏', rid: 4),
        SubChannel(name: '单机游戏', rid: 17),
        SubChannel(name: '电子竞技', rid: 171),
        SubChannel(name: '手机游戏', rid: 172),
        SubChannel(name: '网络游戏', rid: 65),
        SubChannel(name: '桌游棋牌', rid: 173),
        SubChannel(name: 'GMV', rid: 121),
        SubChannel(name: '音游', rid: 136),
      ],
    ),
    MainChannel(
      name: '动画',
      rid: 1,
      icon: Icons.movie_filter_rounded,
      subChannels: [
        SubChannel(name: '全部动画', rid: 1),
        SubChannel(name: 'MAD·AMV', rid: 24),
        SubChannel(name: 'MMD·3D', rid: 25),
        SubChannel(name: '短片·配音', rid: 47),
        SubChannel(name: '手办·模玩', rid: 210),
        SubChannel(name: '特摄', rid: 86),
        SubChannel(name: '综合', rid: 27),
      ],
    ),
    MainChannel(
      name: '科技',
      rid: 188,
      icon: Icons.memory_rounded,
      subChannels: [
        SubChannel(name: '全部科技', rid: 188),
        SubChannel(name: '数码', rid: 95),
        SubChannel(name: '软件应用', rid: 230),
        SubChannel(name: '计算机·网络', rid: 231),
        SubChannel(name: '极客DIY', rid: 232),
        SubChannel(name: '工业·机械', rid: 233),
      ],
    ),
    MainChannel(
      name: '影视',
      rid: 181,
      icon: Icons.live_tv_rounded,
      subChannels: [
        SubChannel(name: '全部影视', rid: 181),
        SubChannel(name: '影视杂谈', rid: 182),
        SubChannel(name: '影视剪辑', rid: 183),
        SubChannel(name: '短片', rid: 85),
        SubChannel(name: '预告·花絮', rid: 184),
      ],
    ),
    MainChannel(
      name: '知识',
      rid: 36,
      icon: Icons.school_rounded,
      subChannels: [
        SubChannel(name: '全部知识', rid: 36),
        SubChannel(name: '科学科普', rid: 201),
        SubChannel(name: '社科·心理', rid: 124),
        SubChannel(name: '人文历史', rid: 228),
        SubChannel(name: '财经商业', rid: 207),
        SubChannel(name: '职业职场', rid: 209),
        SubChannel(name: '设计·创意', rid: 229),
        SubChannel(name: '野生技术协会', rid: 122),
      ],
    ),
    MainChannel(
      name: '美食',
      rid: 211,
      icon: Icons.restaurant_rounded,
      subChannels: [
        SubChannel(name: '全部美食', rid: 211),
        SubChannel(name: '美食制作', rid: 76),
        SubChannel(name: '美食侦探', rid: 212),
        SubChannel(name: '美食测评', rid: 213),
        SubChannel(name: '田园美食', rid: 214),
        SubChannel(name: '美食记录', rid: 215),
      ],
    ),
    MainChannel(
      name: '音乐',
      rid: 3,
      icon: Icons.music_note_rounded,
      subChannels: [
        SubChannel(name: '全部音乐', rid: 3),
        SubChannel(name: '原创音乐', rid: 28),
        SubChannel(name: '翻唱', rid: 31),
        SubChannel(name: 'VOCALOID', rid: 30),
        SubChannel(name: '演奏', rid: 59),
        SubChannel(name: 'MV', rid: 193),
        SubChannel(name: '乐评盘点', rid: 243),
        SubChannel(name: '音乐现场', rid: 29),
      ],
    ),
    MainChannel(
      name: '生活',
      rid: 160,
      icon: Icons.local_florist_rounded,
      subChannels: [
        SubChannel(name: '全部生活', rid: 160),
        SubChannel(name: '搞笑', rid: 138),
        SubChannel(name: '出行', rid: 250),
        SubChannel(name: '三农', rid: 251),
        SubChannel(name: '家居房产', rid: 239),
        SubChannel(name: '手工', rid: 161),
        SubChannel(name: '绘画', rid: 162),
        SubChannel(name: '日常', rid: 21),
      ],
    ),
    MainChannel(
      name: '汽车',
      rid: 223,
      icon: Icons.directions_car_rounded,
      subChannels: [
        SubChannel(name: '全部汽车', rid: 223),
        SubChannel(name: '赛车', rid: 240),
        SubChannel(name: '改装玩车', rid: 241),
        SubChannel(name: '新能源车', rid: 242),
        SubChannel(name: '购车攻略', rid: 244),
        SubChannel(name: '汽车文化', rid: 176),
      ],
    ),
    MainChannel(
      name: '动物圈',
      rid: 217,
      icon: Icons.pets_rounded,
      subChannels: [
        SubChannel(name: '全部动物圈', rid: 217),
        SubChannel(name: '喵星人', rid: 218),
        SubChannel(name: '汪星人', rid: 219),
        SubChannel(name: '大熊猫', rid: 220),
        SubChannel(name: '野生动物', rid: 221),
        SubChannel(name: '爬宠', rid: 222),
      ],
    ),
    MainChannel(
      name: '运动',
      rid: 234,
      icon: Icons.fitness_center_rounded,
      subChannels: [
        SubChannel(name: '全部运动', rid: 234),
        SubChannel(name: '篮球', rid: 235),
        SubChannel(name: '足球', rid: 249),
        SubChannel(name: '健身', rid: 164),
        SubChannel(name: '竞技体育', rid: 236),
        SubChannel(name: '运动文化', rid: 237),
      ],
    ),
    MainChannel(
      name: '鬼畜',
      rid: 119,
      icon: Icons.sentiment_very_satisfied_rounded,
      subChannels: [
        SubChannel(name: '全部鬼畜', rid: 119),
        SubChannel(name: '鬼畜调教', rid: 22),
        SubChannel(name: '音MAD', rid: 26),
        SubChannel(name: '人力VOCALOID', rid: 126),
        SubChannel(name: '鬼畜剧场', rid: 216),
      ],
    ),
  ];
}
