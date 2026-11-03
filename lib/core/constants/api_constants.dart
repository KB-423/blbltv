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

  // 登录与认证 (TV 扫码流)
  static const String qrcodeGenerate =
      '$passportBaseUrl/x/passport-login/web/qrcode/generate';
  static const String qrcodePoll =
      '$passportBaseUrl/x/passport-login/web/qrcode/poll';

  // 搜索
  static const String searchAll = '/x/web-interface/search/all/v2';
  static const String searchSuggest = 'https://s.search.bilibili.com/main/suggest';
}

