import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/tv_theme.dart';

/// 适用于 TV 端并携带 B 站防盗链 Referer 的网络图片组件
class TvNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const TvNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    // 格式化 B 站图片 URL 协议头 (去除 // 开头问题)
    String formattedUrl = imageUrl;
    if (formattedUrl.startsWith('//')) {
      formattedUrl = 'https:$formattedUrl';
    } else if (formattedUrl.startsWith('http://')) {
      formattedUrl = formattedUrl.replaceFirst('http://', 'https://');
    }

    Widget image = Image.network(
      formattedUrl,
      width: width,
      height: height,
      fit: fit,
      headers: const {
        'Referer': ApiConstants.defaultReferer,
        'User-Agent': ApiConstants.defaultUserAgent,
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: TvTheme.tvSurfaceLight,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(TvTheme.biliPink),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: TvTheme.tvSurface,
      child: const Icon(
        Icons.broken_image_rounded,
        color: TvTheme.tvTextDisabled,
        size: 28,
      ),
    );
  }
}

