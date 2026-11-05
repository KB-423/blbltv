import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../core/theme/tv_theme.dart';

/// 播放器极客/调试统计信息面板 (Stats for Nerds)
/// 专门用于在 Debug 模式或测试时显示帧率、硬解/软解状态、解码器、色彩空间(HDR/SDR)、丢帧率与 CDN 节点等
class TvPlayerDebugOverlay extends StatefulWidget {
  final Player? player;
  final String title;
  final int qn;
  final String cdnUrl;

  const TvPlayerDebugOverlay({
    super.key,
    required this.player,
    required this.title,
    required this.qn,
    required this.cdnUrl,
  });

  @override
  State<TvPlayerDebugOverlay> createState() => _TvPlayerDebugOverlayState();
}

class _TvPlayerDebugOverlayState extends State<TvPlayerDebugOverlay> {
  Timer? _refreshTimer;

  // 调试信息字段
  String _hwdec = '检测中...';
  bool _isHardware = false;
  String _videoCodec = '检测中...';
  String _audioCodec = '检测中...';
  String _resolution = '0x0';

  // 真实渲染帧率与丢帧统计
  double _renderedFps = 0.0;
  double _nominalFps = 60.0;
  int _droppedFrames = 0;
  int _dropRatePerSec = 0;
  int _lastDropped = 0;
  DateTime? _lastSampleTime;

  String _sourceColorSpace = 'SDR (Rec.709 8-bit)';
  String _colorRenderMode = 'SDR 原生直通';
  String _bitrate = '0 kbps';
  String _cdnHost = '';

  @override
  void initState() {
    super.initState();
    _extractCdnHost();
    _updateMetrics();
    // 每 1 秒轻量拉取一次实时渲染帧率与解码状态
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateMetrics();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TvPlayerDebugOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cdnUrl != widget.cdnUrl) {
      _extractCdnHost();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _extractCdnHost() {
    if (widget.cdnUrl.isEmpty) {
      _cdnHost = '未获取';
      return;
    }
    try {
      final uri = Uri.parse(widget.cdnUrl);
      _cdnHost =
          '${uri.host}${uri.hasPort && uri.port != 443 && uri.port != 80 ? ':${uri.port}' : ''}';
    } catch (_) {
      _cdnHost = widget.cdnUrl;
    }
  }

  Future<void> _updateMetrics() async {
    final player = widget.player;
    if (player == null) return;

    final state = player.state;
    final dynamic platform = player.platform;

    // 1. 获取当前视频轨信息
    final VideoTrack? currentVideoTrack = state.track.video !=
                VideoTrack.no() &&
            state.track.video != VideoTrack.auto()
        ? state.track.video
        : (state.tracks.video.isNotEmpty ? state.tracks.video.first : null);

    // 2. 解码器与硬解判断
    String decoderDesc = currentVideoTrack?.decoder ?? '';
    String hwdecVal = '';
    try {
      hwdecVal = (await platform?.getProperty(
                'hwdec-current',
                waitForInitialization: false,
              ))
              ?.toString() ??
          '';
    } catch (_) {}

    final bool isHw = (hwdecVal.isNotEmpty && hwdecVal != 'no') ||
        decoderDesc.toLowerCase().contains('mediacodec') ||
        decoderDesc.toLowerCase().contains('hw') ||
        decoderDesc.toLowerCase().contains('vaapi') ||
        decoderDesc.toLowerCase().contains('d3d11va') ||
        decoderDesc.toLowerCase().contains('cuda');

    final String hwdecStr = isHw
        ? '硬解 (${hwdecVal.isNotEmpty && hwdecVal != 'no' ? hwdecVal : (decoderDesc.isNotEmpty ? decoderDesc : 'MediaCodec')})'
        : '软解 (CPU${decoderDesc.isNotEmpty ? ' / $decoderDesc' : ''})';

    // 3. 视频编码
    String vCodec = currentVideoTrack?.codec ?? '';
    if (vCodec.isEmpty) {
      try {
        vCodec = (await platform?.getProperty(
                  'video-codec',
                  waitForInitialization: false,
                ))
                ?.toString() ??
            (await platform?.getProperty(
                  'video-format',
                  waitForInitialization: false,
                ))
                ?.toString() ??
            '';
      } catch (_) {}
    }

    // 4. 统计丢帧总数与实时丢帧速率
    // MPV 正确的丢帧属性为 decoder-frame-drop-count（解码阶段丢帧）与 frame-drop-count（VO呈现阶段丢帧）
    int dropped = 0;
    try {
      final decDropStr = (await platform?.getProperty(
                'decoder-frame-drop-count',
                waitForInitialization: false,
              ))
              ?.toString() ??
          '0';
      final voDropStr = (await platform?.getProperty(
                'frame-drop-count',
                waitForInitialization: false,
              ))
              ?.toString() ??
          '0';
      dropped =
          (int.tryParse(decDropStr) ?? 0) + (int.tryParse(voDropStr) ?? 0);
    } catch (_) {}

    final now = DateTime.now();
    final double elapsedSec = _lastSampleTime != null
        ? now.difference(_lastSampleTime!).inMilliseconds / 1000.0
        : 1.0;
    _lastSampleTime = now;

    // 计算当前采样周期的丢帧增量 (dropDelta)
    final int dropDelta = (dropped >= _lastDropped && _lastDropped > 0)
        ? (dropped - _lastDropped)
        : 0;
    _lastDropped = dropped;
    final int dropRate =
        elapsedSec > 0 ? (dropDelta / elapsedSec).round() : dropDelta;

    // 5. 片源标称帧率与真实有效渲染帧率
    double sourceFps = currentVideoTrack?.fps ?? 0.0;
    if (sourceFps <= 0.0) {
      try {
        final fpsStr = (await platform?.getProperty(
                  'container-fps',
                  waitForInitialization: false,
                ))
                ?.toString() ??
            '';
        sourceFps = double.tryParse(fpsStr) ?? 0.0;
      } catch (_) {}
    }
    if (sourceFps <= 0.0) sourceFps = 60.0;

    // 核心算法：真实有效渲染帧率 (Actual Rendered FPS)
    // 优先读取 MPV 内部视频滤镜实时输出帧率 estimated-vf-fps（当软解卡死或掉帧时该值会真实下跌）
    double actualRenderedFps = 0.0;
    try {
      final evfStr = (await platform?.getProperty(
                'estimated-vf-fps',
                waitForInitialization: false,
              ))
              ?.toString() ??
          '';
      final evf = double.tryParse(evfStr);
      if (evf != null && evf > 0.0) {
        actualRenderedFps = evf;
      }
    } catch (_) {}

    if (actualRenderedFps <= 0.0 && state.playing) {
      // 备用计算：标称帧率扣除实时丢帧速率
      actualRenderedFps =
          sourceFps - (elapsedSec > 0 ? (dropDelta / elapsedSec) : 0.0);
    }
    if (actualRenderedFps < 0.0) actualRenderedFps = 0.0;
    if (actualRenderedFps > sourceFps + 1.0) actualRenderedFps = sourceFps;
    if (!state.playing) actualRenderedFps = 0.0;

    // 6. 画面分辨率 (优先从 state/videoParams 获取)
    final int w =
        state.width ?? state.videoParams.w ?? currentVideoTrack?.w ?? 0;
    final int h =
        state.height ?? state.videoParams.h ?? currentVideoTrack?.h ?? 0;
    final String resStr = w > 0 && h > 0 ? '$w x $h' : '缓冲就绪中';

    // 7. 色彩空间：精准区分【片源原始色域】与【输出渲染模式】
    final videoParams = state.videoParams;
    final String colormatrix = videoParams.colormatrix ?? '';
    final String gamma = videoParams.gamma ?? '';
    final String pixFmt = videoParams.pixelformat ?? '';
    final String primaries = videoParams.primaries ?? '';

    // 判断片源是否为 HDR (qn 125/126 或具备 BT.2020/PQ/HLG/10-bit 特征)
    final bool isHdrSource = widget.qn == 125 ||
        widget.qn == 126 ||
        gamma.toLowerCase().contains('pq') ||
        gamma.toLowerCase().contains('hlg') ||
        colormatrix.toLowerCase().contains('2020') ||
        primaries.toLowerCase().contains('2020') ||
        pixFmt.toLowerCase().contains('10') ||
        pixFmt.toLowerCase().contains('p010');

    String sourceColor;
    String renderMode;

    if (isHdrSource) {
      final matrixDesc =
          colormatrix.isNotEmpty ? colormatrix.toUpperCase() : 'BT.2020';
      final gammaDesc = gamma.isNotEmpty
          ? gamma.toUpperCase()
          : (widget.qn == 126 ? 'Dolby Vision' : 'PQ');
      sourceColor = 'HDR10 ($matrixDesc / $gammaDesc 10-bit)';

      // 输出渲染模式 (已开启 target-colorspace-hint 硬件直通)
      renderMode = '${widget.qn == 126 ? "杜比视界" : "HDR10"} 硬件直通 (Passthrough)';
    } else {
      final matrixDesc =
          colormatrix.isNotEmpty ? colormatrix.toUpperCase() : 'Rec.709';
      sourceColor = 'SDR ($matrixDesc 8-bit)';
      renderMode = 'SDR 原生直通 (Rec.709)';
    }

    // 8. 瞬时码率
    String bitrateStr = '';
    final int? trackBitrate = currentVideoTrack?.bitrate;
    if (trackBitrate != null && trackBitrate > 0) {
      bitrateStr = '${(trackBitrate / 1000).toStringAsFixed(1)} kbps';
    } else {
      try {
        final bStr = (await platform?.getProperty(
                  'video-bitrate',
                  waitForInitialization: false,
                ))
                ?.toString() ??
            '';
        final bNum = double.tryParse(bStr) ?? 0.0;
        if (bNum > 0) {
          bitrateStr = '${(bNum / 1000).toStringAsFixed(1)} kbps';
        }
      } catch (_) {}
    }

    // 9. 音频解码与音轨状态
    final AudioTrack? currentAudioTrack = state.track.audio !=
                AudioTrack.no() &&
            state.track.audio != AudioTrack.auto()
        ? state.track.audio
        : (state.tracks.audio.isNotEmpty ? state.tracks.audio.first : null);
    String aCodec = currentAudioTrack?.codec ?? '';
    if (aCodec.isEmpty) {
      try {
        aCodec = (await platform?.getProperty(
                  'audio-codec-name',
                  waitForInitialization: false,
                ))
                ?.toString() ??
            '';
      } catch (_) {}
    }
    if (aCodec.isNotEmpty) {
      aCodec = '${aCodec.toUpperCase()} (DASH音轨激活)';
    } else {
      aCodec = 'AAC (DASH音轨激活)';
    }

    if (!mounted) return;

    setState(() {
      _hwdec = hwdecStr;
      _isHardware = isHw;
      _videoCodec = vCodec.isNotEmpty ? vCodec : '自动协商中';
      _audioCodec = aCodec;
      _renderedFps = actualRenderedFps;
      _nominalFps = sourceFps;
      _resolution = resStr;
      _sourceColorSpace = sourceColor;
      _colorRenderMode = renderMode;
      _droppedFrames = dropped;
      _dropRatePerSec = dropRate;
      _bitrate = bitrateStr.isNotEmpty ? bitrateStr : '动态码率';
    });
  }

  @override
  Widget build(BuildContext context) {
    // 渲染帧率颜色判定
    Color fpsColor = Colors.greenAccent;
    if (_nominalFps > 0) {
      final double ratio = _renderedFps / _nominalFps;
      if (ratio < 0.6) {
        fpsColor = Colors.redAccent;
      } else if (ratio < 0.9) {
        fpsColor = Colors.amberAccent;
      }
    }

    final bool isHdr = _sourceColorSpace.contains('HDR');

    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TvTheme.biliPink.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题与状态指示灯
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    size: 16,
                    color: TvTheme.biliPink,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '播放器极客信息 (Debug)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHardware ? Colors.greenAccent : Colors.orangeAccent,
                  boxShadow: [
                    BoxShadow(
                      color: (_isHardware
                              ? Colors.greenAccent
                              : Colors.orangeAccent)
                          .withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 10),

          // 指标列表
          _buildItem(
            '解码加速',
            _hwdec,
            color: _isHardware ? Colors.greenAccent : Colors.amberAccent,
            isBold: true,
          ),
          _buildItem('视频编码', _videoCodec.toUpperCase()),
          _buildItem(
            '实时帧率',
            '${_renderedFps.toStringAsFixed(1)} FPS  (源: ${_nominalFps.toStringAsFixed(1)})',
            color: fpsColor,
            isBold: true,
          ),
          _buildItem('画面尺寸', _resolution),
          _buildItem(
            '片源色域',
            _sourceColorSpace,
            color: isHdr ? Colors.cyanAccent : Colors.white70,
            isBold: isHdr,
          ),
          _buildItem(
            '色彩渲染',
            _colorRenderMode,
            color: isHdr ? Colors.amberAccent : Colors.white60,
            isBold: isHdr,
          ),
          _buildItem(
            '音频解码',
            _audioCodec,
            color: Colors.lightGreenAccent,
          ),
          _buildItem('瞬时码率', _bitrate),
          _buildItem(
            '丢帧统计',
            '$_droppedFrames 帧${_dropRatePerSec > 0 ? ' (+$_dropRatePerSec 帧/秒)' : ''}',
            color: _dropRatePerSec > 0 ? Colors.redAccent : Colors.white70,
            isBold: _dropRatePerSec > 0,
          ),
          _buildItem('CDN 节点', _cdnHost, isSmall: true),
        ],
      ),
    );
  }

  Widget _buildItem(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: isSmall ? 10.5 : 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
