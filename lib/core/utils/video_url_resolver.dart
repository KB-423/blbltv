/// B 站流媒体 CDN 解析与 PCDN/MCDN 清洗工具
/// 解决电视盒子与路由器拦截 MCDN (:8082 等非标端口) 导致 ffurl_read 报错 0xffffff92 的问题
class VideoUrlResolver {
  /// 官方稳定高速 CDN 镜像 (腾讯云 upos 镜像，全国各大运营商连通性极高)
  static const String defaultCdnHost = 'upos-sz-mirrorcos.bilivideo.com';

  /// 判断是否为 PCDN / MCDN / 边缘小运营商不稳定节点
  static bool isMcdnOrPcdn(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.contains('.mcdn.bilivideo') ||
        lower.contains('szbdyd.com') ||
        lower.contains(':8082') ||
        lower.contains(':8000') ||
        RegExp(r'^https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(lower);
  }

  /// 从音视频轨数据中智能优选最优 CDN 链接
  /// 优先提取非 PCDN/MCDN 的备用链接 (backupUrl)；
  /// 若全部包含 MCDN，则强制重写 Host 为官方主站 CDN 镜像并将端口置为 443。
  static String resolveUrl(Map<String, dynamic> track) {
    final List<String> candidates = [];

    // 1. 收集 baseUrl
    final base = (track['baseUrl'] ?? track['base_url'])?.toString();
    if (base != null && base.isNotEmpty) {
      candidates.add(base);
    }

    // 2. 收集 backupUrl 列表
    final backups = track['backupUrl'] ?? track['backup_url'];
    if (backups is List) {
      for (final b in backups) {
        final bStr = b?.toString();
        if (bStr != null && bStr.isNotEmpty) {
          candidates.add(bStr);
        }
      }
    }

    if (candidates.isEmpty) return '';

    // 3. 优先寻找非 MCDN 的优质 CDN 链接
    String chosen = '';
    for (final url in candidates) {
      if (!isMcdnOrPcdn(url)) {
        chosen = url;
        break;
      }
    }

    // 4. 若所有链接均为 MCDN，取首个进行重写清洗
    if (chosen.isEmpty) {
      chosen = candidates.first;
    }

    return cleanUrl(chosen);
  }

  /// 清洗 URL：若属于 MCDN/PCDN 或带非标端口，替换为官方稳定镜像
  static String cleanUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';

    try {
      final uri = Uri.parse(rawUrl);

      // 若包含 MCDN、szbdyd 或 8082 端口，强制替换为官方高速镜像
      if (isMcdnOrPcdn(rawUrl)) {
        String targetHost = defaultCdnHost;
        final xyUsource = uri.queryParameters['xy_usource'];
        if (xyUsource != null &&
            xyUsource.isNotEmpty &&
            !xyUsource.contains('mcdn')) {
          targetHost = xyUsource;
        }

        return uri.replace(
          scheme: 'https',
          host: targetHost,
          port: 443,
        ).toString();
      }

      return rawUrl;
    } catch (_) {
      return rawUrl;
    }
  }
}

