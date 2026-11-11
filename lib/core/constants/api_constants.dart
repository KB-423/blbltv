/// Bilibili 常用 API 端点常量定义
/// 参考 third/lib/http/api.dart
class ApiConstants {
  ApiConstants._();

  // 基础域名
  static const String webBaseUrl = 'https://api.bilibili.com';
  static const String appBaseUrl = 'https://app.bilibili.com';
  static const String passportBaseUrl = 'https://passport.bilibili.com';
  static const String liveBaseUrl = 'https://api.live.bilibili.com';
  static const String vcBaseUrl = 'https://api.vc.bilibili.com';

  // 默认请求头 Referer 与 User-Agent
  static const String defaultReferer = 'https://www.bilibili.com';
  static const String defaultUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  // 首页与推荐
  static const String recommendFeedWeb = '/x/web-interface/index/top/feed/rcmd';
  static const String popularVideos = '/x/web-interface/popular';
  static const String navUserInfo = '/x/web-interface/nav';

  // 视频相关
  static const String videoDetail = '/x/web-interface/view';
  static const String videoPlayUrl = '/x/player/wbi/playurl';
  static const String bangumiPlayUrl = '/pgc/player/web/playurl';
  static const String videoHeartbeat = '/x/click-interface/web/heartbeat';
  static const String playerPageList = '/x/player/pagelist';
  static const String onlineTotal = '/x/player/online/total';
  static const String hasLikeVideo = '/x/web-interface/archive/has/like';
  static const String likeVideo = '/x/web-interface/archive/like';
  static const String hasCoinVideo = '/x/web-interface/archive/coins';
  static const String coinVideo = '/x/web-interface/coin/add';
  static const String hasFavVideo = '/x/v2/fav/video/favoured';
  static const String addFavVideo = '/x/v3/fav/resource/deal';
  static const String tripleLike = '$appBaseUrl/x/v2/view/like/triple';
  static const String relatedVideos = '/x/web-interface/archive/related';
  static const String upSpaceVideos = '/x/space/wbi/arc/search';

  // 专区端点 (热门、直播、番剧、频道/分区)
  static const String liveList = '$liveBaseUrl/xlive/web-interface/v1/index/getList';
  static const String livePlayInfo = '$liveBaseUrl/xlive/web-room/v2/index/getRoomPlayInfo';
  static const String bangumiSeasonIndex = '/pgc/season/index/result';
  static const String bangumiSeasonInfo = '/pgc/view/web/season';
  static const String channelRankingRegion = '/x/web-interface/ranking/region';

  // 登录与认证 (TV 扫码流)
  static const String qrcodeGenerate =
      '$passportBaseUrl/x/passport-login/web/qrcode/generate';
  static const String qrcodePoll =
      '$passportBaseUrl/x/passport-login/web/qrcode/poll';

  // 用户与个人资产 (历史记录、收藏夹、追番)
  static const String historyList = '/x/web-interface/history/cursor';
  static const String userFavFolders = '/x/v3/fav/folder/created/list-all';
  static const String userFavResources = '/x/v3/fav/resource/list';
  static const String bangumiFollow = '/x/space/bangumi/follow/list';
  static const String navStat = '/x/web-interface/nav/stat';

  // 搜索
  static const String searchAll = '/x/web-interface/search/all/v2';
  static const String searchSuggest = 'https://s.search.bilibili.com/main/suggest';
  static const String searchByType = '/x/web-interface/wbi/search/type';
  static const String hotSearchList = 'https://s.search.bilibili.com/main/hotword';
}
