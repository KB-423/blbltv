# AGENTS.md - Bili for TV 开发与架构规范

> **适用对象**：所有在此仓库中进行代码编写、架构设计、重构与排错的 AI 编码智能体（AI Agents）及开发者。
> **项目定位**：基于 Flutter 的第三方大屏客户端（Android TV / 电视盒子 / 投影仪），以遥控器交互与 10-foot UI 为核心体验。
> **技术合规与边界**：本项目纯粹用于个人技术学习、跨端大屏架构研究与开源技术交流，**严禁用于任何商业运营、盈利活动或公开发布**。

---

## 1. 核心技术栈与架构准则

| 维度 | 选型与版本 | 职责与规范 |
| :--- | :--- | :--- |
| **语言与框架** | Flutter (Dart 3.x) | 充分运用 Dart 3 模式匹配、Records、Sealed Classes 与严格空安全。 |
| **状态管理** | `flutter_riverpod: ^3.4.3` | **严禁引入 GetX**。所有业务状态统一采用 `AsyncNotifier` / `Notifier` / `Provider`，业务与 UI 严格解耦。 |
| **路由导航** | `go_router: ^18.1.2` | 声明式路由管理。使用 `ShellRoute` 承载 TV 左侧导轨，全屏播放器使用独立 Root 路由（暴露 `rootNavigatorKey`）。 |
| **数据建模** | `freezed: ^4.0.3` + `json_serializable` | 不可变数据模型，自动实现 `copyWith`、`fromJson`/`toJson` 与深层对比。 |
| **网络层** | `dio: ^5.11.1` + `cookie_jar: ^4.0.9` | 统一会话管理、Cookie 持久化、Wbi 请求签名拦截器、Buvid 设备标识、防盗链 Referer 注入。 |
| **持久化** | `shared_preferences: ^2.5.6` | 轻量化本地偏好与会话存储，通过 Riverpod 统一注入。 |
| **代码生成** | `build_runner: ^2.17.1` | 自动生成 `.freezed.dart` 与 `.g.dart`。 |
| **TV 交互** | `dpad: ^3.1.1` | **统一且必须使用 `dpad` 库** 处理 TV 遥控器与焦点，**严禁自行手写 tvfocus**。 |
| **数据源与真实性** | 真实 API，**严格零 Mock** | **生产代码严禁使用或写入任何 Mock 数据 / 假数据 / 兜底假链接**。网络或接口异常一律向上抛出并走 UI 错误重试。 |

---

## 2. 遥控器与大屏焦点核心准则 (`dpad`)

项目已引入专门的大屏焦点库 `package:dpad/dpad.dart`，**所有 TV 交互必须严格遵守以下规范，严禁自行手写 Focus/InkWell 轮子**：

### 2.1 根组件挂载与层级
在 `MaterialApp.router` 或 `MaterialApp` 中通过 `builder` 挂载 `Dpad.wrap()`。若挂载全局调试遥控器，**必须将调试遥控器作为 `Dpad.wrap()` 的直接子组件**，以确保内部可以通过 `Dpad.maybeOf(context)` 获取控制器：

```dart
MaterialApp.router(
  routerConfig: router,
  builder: (context, child) {
    return Dpad.wrap(
      onBlockedMove: (direction) {
        if (direction == TraversalDirection.left) {
          ref.read(navRailFocusServiceProvider).focusSelected();
        }
      },
      theme: const DpadThemeData(...),
    )(
      context,
      TvDebugRemoteOverlay(child: child ?? const SizedBox.shrink()),
    );
  },
)
```

### 2.2 可聚焦组件与区域管理规范
所有需要被遥控器落焦与点击的组件，**一律使用 `DpadFocusable` 包裹**；每个独立的内容模块与结构区块，**必须使用 `DpadRegion` 包裹**：

```dart
import 'package:dpad/dpad.dart';

DpadRegion(
  enter: DpadEnterBehavior.restore, // 区域切出切回时保持焦点记忆
  horizontalEdge: DpadEdgeBehavior.stop, // 阻止左右意外逃逸跨界
  verticalEdge: DpadEdgeBehavior.leave,
  child: DpadFocusable(
    autofocus: true, // 可选：进入页面默认落焦
    onSelect: () {   // 遥控器 OK / 确定键响应
      context.push('/player/BVxxxx');
    },
    child: VideoCard(video),
  ),
)
```

- **按键响应**：确定事件使用 `onSelect`，长按（如呼出菜单）使用 `onLongSelect`。
- **动效与主题**：高亮边框、缩放与阴影优先使用 `dpad` 自带的 `DpadTheme` 与 `DpadEffect` 机制。

### 2.3 区域隔离与嵌套防串焦规范 (DpadRegion Nesting & Boundaries)
* **根因与问题**：Flutter 系统默认的几何方向寻焦（`DirectionalFocusTraversalPolicy`）会寻找物理空间最近的组件。当上下两个不同结构（如上方的顶部操作工具栏与下方的多列视频网格）并排存在时，若未作区域隔离，在顶部按左右方向键会意外“斜向走焦”直接串到下方的卡片网格中，严重破坏大屏空间心智模型。
* **架构规范**：
  1. **各独立内容区域必须使用 `DpadRegion` 包裹**（如侧边导轨区、顶部工具栏区、中间内容网格区、底部操作区分离）；
  2. **不同层级与业务结构必须进行 `DpadRegion` 嵌套包裹**，通过配置 `horizontalEdge: DpadEdgeBehavior.stop` 或 `verticalEdge: DpadEdgeBehavior.leave` 明确边界流转规则，**坚决杜绝上下的内容在按左右键时意外横跨走过去**；
  3. 任何需要遥控器响应的内容单元必须包裹 `DpadFocusable`，杜绝任何未受纳管的裸聚焦或手写 FocusNode 绕过机制。

### 2.4 初始焦点默认定向准则 (Default Initial Focus Traversal)
为了保证大屏开屏、切屏与弹窗时遥控器落点的确定性与一致性：
1. **水平方向默认最左侧为初始落焦点**：所有横向排布的 Tab 栏、工具按钮组、横向筛选列表，默认将第 0 项（最左）设为默认或首项进入焦点；
2. **垂直方向默认最顶部为初始落焦点**：所有纵向列表、多列卡片网格、设置页列表，默认将第 0 行/首项卡片作为默认进入焦点；
3. **播放器页面以视频画面本身为初始焦点**：全屏播放器进入时，必须默认将第一焦点锚定在全屏视频画面容器（`_videoFocusNode`），用户按确定键或方向键时才唤起浮层控制栏并进行焦点交接；退出控制栏时立即自愈抓回视频画面；
4. **弹窗与浮层同理**：画质面板、选集抽屉等进入时，默认落焦在当前正在生效的选项（或第 0 项），收起时严密回交原宿主节点。

### 2.5 动态浮层销毁与焦点自愈机制 (Focus Self-Healing)
* **根因**：TV 场景下当弹出浮层（如播放器控制栏、画质选择面板）自动超时隐藏或卸载（unmount）时，原本处于浮层内部的焦点会被 Flutter 系统直接释放为 `null`，导致页面无法再接收任何按键事件（如返回键失效、快进快退失效）。
* **规范**：
  1. 页面全屏根容器必须持有一个专属且固定的 `FocusNode`（如 `_playerFocusNode`）；
  2. 使用 Riverpod 的 `ref.listen` 监听浮层关闭状态，在关闭发生后的下一帧通过 `WidgetsBinding.instance.addPostFrameCallback` 立即抓回焦点：
     ```dart
     ref.listen(playerProvider(bvid).select((s) => s.showControls), (prev, show) {
       if (prev == true && !show) {
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) _playerFocusNode.requestFocus();
         });
       }
     });
     ```

### 2.6 TV 文本输入框与软键盘调起规范
* **遥控器按键映射**：遥控器 OK 键发送的是 `LogicalKeyboardKey.select`（Android `KEYCODE_DPAD_CENTER`），Flutter `TextField` 默认只监听 `Enter`。输入框必须包裹在 `DpadFocusable(excludeChildFocus: false)` 中，并在 `Focus(onKeyEvent: ...)` 与 `onTap` 中统一拦截 `select`、`enter`、`gameButtonA` 触发输入法。
* **物理键盘策略穿透 (`SHOW_FORCED`)**：当大屏外接遥控器或物理设备时，Android 默认判定有物理键盘并隐藏虚拟软键盘（`show_ime_with_hard_keyboard = 0`）。必须在原生 `MainActivity.kt` 开辟 MethodChannel，配合 `InputMethodManager.SHOW_FORCED` 强制调起系统输入法。

### 2.7 平板/PC 调试虚拟遥控器规范 (`TvDebugRemoteOverlay`)
* **运行隔离**：严格通过 `if (!kDebugMode) return widget.child;` 隔离，Release 构建零开销且完全不可见；
* **焦点隔离 (`ExcludeFocus`)**：虚拟遥控器整体容器必须使用 `ExcludeFocus(excluding: true)` 包裹，**彻底杜绝触控点击遥控器时夺走或清除主界面中正在落焦的 TV 组件焦点**；
* **禁止重复位移 (消除“跳两下”)**：
  * 按下按键投递 `KeyDownEvent` 已经由系统 `DirectionalFocusAction` / `DpadTraversalPolicy` 驱动移动了一步；
  * **松手或结束时严禁再次调用 `dpad.move()`**，否则会导致单次点击连续位移两次；
* **物理时序分离**：
  * **单次轻触**：投递 `KeyDown`，50ms 后投递 `KeyUp`；
  * **长按快进/快退**：按下立即投递 `KeyDown`，超过 220ms 周期投递 `KeyRepeat`（驱动播放器长按快进/快退 HUD 累计计时），松手投递 `KeyUp`（触发最终 seek 跳转）；
  * **触控零延迟**：方向按键优先采用原生 `Listener(onPointerDown, onPointerUp)`，杜绝 `GestureDetector` 内部 `GestureArena` 竞技裁决产生的 500ms 延迟。

### 2.8 全量动效组件强制规范 (Animated Widgets Mandate)
* **核心准则**：在 TV 场景中，生硬无过渡的状态突变（如尺寸跳变、显隐骤变、颜色突变）会严重破坏大屏 10-foot UI 的高级感与沉浸感。**项目要求所有具有 `Animated*` 版本的 Flutter 组件，必须全量且统一使用其对应 Animated 版本**：
  * `Container` 涉及边框、背景色、圆角、内外边距或宽高变化时，**必须使用 `AnimatedContainer`**；
  * `Opacity` 显隐过渡一律使用 **`AnimatedOpacity`**；
  * `Padding` 边距动态伸缩一律使用 **`AnimatedPadding`**；
  * `Positioned` 绝对位置流转一律使用 **`AnimatedPositioned`**；
  * 区域高度/宽度折叠展开（如顶部第二行隐藏不再占用高度、合集抽屉伸缩）一律使用 **`AnimatedSize`** 或 **`AnimatedCrossFade`**；
  * 画面与抽屉滑移一律使用 **`AnimatedSlide`**；
  * 字体样式或颜色变更一律使用 **`AnimatedDefaultTextStyle`**；
  * 组件内容切换一律使用 **`AnimatedSwitcher`**。
* **参数配置**：所有动效默认时长建议控制在 200ms ~ 320ms，曲线统一优先采用 `Curves.easeOutCubic` 或 `Curves.easeInOutCubic`，保证丝滑跟随遥控器操作且无拖沓。

---

## 3. 代码生成与 `build_runner` 工作流 (Build Runner Directives)

根据项目根目录 `build.yaml` 的配置，**所有生成的源码必须严格隔离到同级 `generated/` 子目录中**：

```yaml
targets:
  $default:
    builders:
      source_gen:combining_builder:
        options:
          build_extensions:
            "{{dir}}/{{file}}.dart": "{{dir}}/generated/{{file}}.g.dart"
      freezed:freezed:
        options:
          build_extensions:
            "{{dir}}/{{file}}.dart": "{{dir}}/generated/{{file}}.freezed.dart"
```

### 3.1 模型与 Part 编写规则
编写任何 Freezed 数据模型或使用 `json_serializable` 时，**必须使用带 `generated/` 路径的 part 声明**：

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/example_model.freezed.dart';
part 'generated/example_model.g.dart';

@freezed
abstract class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    required String id,
    required String title,
    @Default(0) int viewCount,
  }) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
}
```

### 3.2 触发代码生成指令
只要新增或修改了带有 `@freezed`、`@JsonSerializable` 或注解的类，Agent 必须通过命令行执行构建：

```bash
# 执行代码生成构建
dart run build_runner build

# 若遇到输出冲突时执行清理构建
dart run build_runner build --delete-conflicting-outputs
```

> **注意**：切勿手动编辑或篡改 `generated/` 目录中的任何生成代码。

---

## 4. 参考资产映射与重构策略 (`third/lib` -> `lib/`)

项目在 `third/lib` 存放了优秀的移动端参考源码（PiliPalaX）。Agent 在实现功能时应积极借鉴其协议解析与业务逻辑，但必须遵守以下重构映射法则：

```text
third/lib/ (参考源)                 lib/ (现代 TV 架构)
├── http/api.dart           ──>   lib/core/constants/api_constants.dart (端点常量)
├── http/init.dart          ──>   lib/core/network/api_client.dart (Dio + CookieJar + 拦截器)
├── utils/wbi_sign.dart     ──>   lib/core/utils/wbi_signer.dart (Wbi 签名算法)
├── models/                 ──>   lib/models/ (重构成 Freezed + json_serializable)
├── pages/login/            ──>   lib/features/user/ (重构为 TV 二维码扫码登录)
├── pages/home/             ──>   lib/features/home/ (重构为大屏 4 列网格 + D-Pad 导航)
├── pages/video/            ──>   lib/features/player/ (重构为 TV 遥控器全屏播放器)
└── router/app_pages.dart   ──>   lib/router/app_router.dart (GetX 路由重构为 GoRouter)
```

### 关键业务逻辑移植要点：
1. **Wbi 签名机制**：
   B 站大多数 Web 接口（如首页推荐 `/x/web-interface/index/top/feed/rcmd`）强制需要 Wbi 签名。调用前必须提取 `img_key` 和 `sub_key` 并按字典序排列参数拼接 MD5。
2. **防盗链 Header 与 MCDN 节点过滤**：
   - 请求 B 站图片与视频流时，必须在 Header 中附加 `Referer: https://www.bilibili.com` 与合规 `User-Agent`；
   - 必须通过 `VideoUrlResolver` 剔除含有 `mcdn.bilivideo.cn` / `pcdn` 的边缘不稳定节点，改写为主站官方高速 CDN 镜像。
3. **免密码 TV 扫码登录**：
   TV 场景坚决摒弃账号密码输入框。使用 `/x/passport-login/web/qrcode/generate` 并在大屏渲染高清二维码，后台轮询 `/x/passport-login/web/qrcode/poll`，成功后提取 Cookie 存入 `cookie_jar`。
4. **播放器生命周期与音画同步防坑指南**：
   - **退出彻底掐断音频**：播放器 `dispose`、`PopScope` 退出以及 `ref.onDispose` 必须同步执行 `player.stop()`，杜绝退出界面后声音继续播放；
   - **音画时钟基准同步**：外挂独立 DASH 音频流与视频流混合解复用时，底层必须开启 `'video-sync': 'audio'`, `'hr-seek': 'yes'`, `'hr-seek-framedrop': 'yes'`, `'autosync': '30'`；
   - **进度条闪烁抑制**：起播时 MPV 底层会广播 0 秒初始事件，状态机必须采用 `isWaitingInitialSeek` 闸门过滤，严禁在业务层增加 300ms 二次 seek；
   - **画质切换记忆续播**：画质变更时提取当前精准进度，换流起播后直接定位至记忆位置，绝不重新从头播放；
   - **多级分层返回拦截**：全屏播放器 `PopScope` 设置为 `canPop: false`，遵循分级返回策略：画质面板 $\to$ 控制栏 $\to$ 退出播放器。
5. **硬件解码优先与掉帧优化策略**：
   - 在选择流轨道时按 **HEVC (H.265, codecid: 12) > AV1 (codecid: 13, 针对 4K/8K/1080P60 专用大屏 ASIC 硬解) > AVC (H.264, codecid: 7)** 智能排序；
   - 彻底避免在 4K 60fps 等超高清规格下选用高码率 AVC（H.264 硬件解码器大多受限于 Level 5.2，4K 60fps 会导致 70%+ 灾难性丢帧），充分利用大屏现代 SOC（如联发科 Pentonic MT5877/MT9655）的 `c2.mtk.hevc.decoder` 与 `c2.mtk.av1.decoder` 硬件解码流水线。
6. **云端心跳与观看历史同步**：
   - 起播、每 15 秒以及退出播放器时，必须调用 `POST /x/click-interface/web/heartbeat`；
   - 从 Cookie 中提取 `bili_jct` (csrf token) 并携带 `played_time`，确保视频播放真实写入云端历史记录。
7. **严格零 Mock 原则 (Zero Mock Policy)**：
   - **生产代码零 Mock**：`lib/` 源码中严禁编写或保留任何硬编码的假数据、伪造 BVID/CID、兜底写死的视频流链接或本地模拟列表。
   - **真实错误传播**：网络异常、接口限流、风控或未登录时，必须将真实错误状态向上抛出并交由 Riverpod 状态层管理，由 UI 层展示标准的 `TvErrorView` 错误提示并提供遥控器重试按钮，严禁静默降级为假数据。

---

## 5. 项目目录结构规范

```text
lib/
├── core/                           # 基础设施与全局公用能力
│   ├── constants/                  # API 常量与尺寸配置 (api_constants.dart, app_constants.dart)
│   ├── network/                    # 网络客户端与拦截器 (api_client.dart, api_response.dart)
│   ├── storage/                    # 本地数据持久化 (storage_service.dart)
│   ├── theme/                      # TV 暗色主题与色盘 (tv_theme.dart)
│   └── utils/                      # Wbi 签名、URL 优选、计数/时长格式化 (wbi_signer.dart, video_url_resolver.dart)
│
├── models/                         # 领域实体模型 (全部使用 Freezed 声明)
│   ├── common/                     # 通用包装类 (api_response_model.dart 等)
│   ├── user/                       # 用户数据模型 (user_info_model.dart)
│   └── video/                      # 视频与卡片数据模型 (video_item_model.dart, play_url_model.dart)
│       └── generated/              # 由 build_runner 生成的 .freezed.dart 和 .g.dart
│
├── widgets/                        # TV 专用核心基础控件
│   ├── tv_scaffold.dart            # 大屏防切边脚手架
│   ├── tv_image.dart               # 带防盗链 Referer 的图片组件
│   ├── tv_status_view.dart         # 大屏加载中、错误重试与空状态
│   └── tv_debug_remote_overlay.dart# 平板/PC 专用 Debug 虚拟遥控器浮层
│
├── router/                         # 路由配置
│   ├── route_paths.dart            # 路由静态常量
│   └── app_router.dart             # GoRouter 配置（ShellRoute 承载侧边导轨，导出 rootNavigatorKey）
│
├── features/                       # 业务功能模块 (按 Feature 划分，避免一次性生成全量未验证代码)
│   ├── main/                       # TV 外壳容器与左侧导航导轨 (tv_main_shell.dart, tv_nav_rail.dart)
│   ├── home/                       # 首页推荐流 (screens/, providers/, repositories/, widgets/)
│   ├── popular/                    # 热门专区
│   ├── live/                       # 直播专区
│   ├── bangumi/                    # 追番与影视
│   ├── search/                     # 大屏检索（支持电视系统输入法）
│   ├── player/                     # TV 视频播放器核心（全屏控制栏、画质面板、极客调试面板）
│   ├── user/                       # 个人中心与扫码登录
│   └── settings/                   # 播放设置与系统设置
│
└── main.dart                       # 应用程序统一入口
```

---

## 6. Agent 编码质量与自检清单 (Verification Checklist)

Agent 在每次提交代码变更或完成任务前，必须执行以下自检：

- [ ] **不要自己写 tvfocus**：是否全部采用 `dpad` (`DpadFocusable`、`DpadRegion`、`Dpad.wrap()`)？
- [ ] **DpadRegion 嵌套与边界隔离**：各内容区域是否包裹 DpadRegion？上下不同结构是否嵌套隔离并配置边界行为，杜绝左右键意外串焦？
- [ ] **初始焦点默认定向**：水平方向是否默认最左为首焦，垂直方向默认最上为首焦，播放器进入是否默认以视频画面为首焦？
- [ ] **浮层焦点自愈**：播放器控制栏或弹窗浮层收起后，是否已通过 `ref.listen` 及时将焦点抓回根节点，杜绝焦点丢失？
- [ ] **按键时序纯粹性**：虚拟遥控器是否已包裹 `ExcludeFocus`？方向键是否仅通过单一硬件按键事件分发，杜绝一次点击位移两次？
- [ ] **播放器退出彻底**：退出播放器是否已调用 `player.stop()` 并安全 `dispose()`，杜绝声音继续残留？
- [ ] **多级返回不卡死**：全屏播放器是否通过 `canPop: false` 与 `_handleBack` 严格遵循“画质面板 $\to$ 控制栏 $\to$ 退出界面”的分级退出逻辑？
- [ ] **软键盘 TV 适配**：文本输入框是否采用 `DpadFocusable(excludeChildFocus: false)`，并支持遥控器 `Select` / `Enter` 键唤起输入法？
- [ ] **严格零 Mock**：生产代码（`lib/`）中是否彻底杜绝了任何 Mock/Fake/兜底假数据？错误是否真实传播至 UI？临时测试数据是否已全部清理？
- [ ] **全量 Animated 组件规范**：所有涉及过渡、状态变化、显隐或尺寸伸缩的组件，是否已全部采用对应的 Animated 变体（如 AnimatedContainer, AnimatedOpacity, AnimatedSize, AnimatedSlide, AnimatedPositioned 等）？
- [ ] **代码生成校验**：是否运行了 `dart run build_runner build` 并确保所有生成文件（`generated/*.freezed.dart`, `generated/*.g.dart`）正常同步。
- [ ] **静态分析无报错**：运行 `flutter analyze` 或确认无严重警告与编译错误。
- [ ] **音画同步与硬件解码**：播放器配置是否开启了 `video-sync=audio`？画质选择是否优先调度了 HEVC 硬解流？
- [ ] **保持非商业合规**：代码与注释严禁包含任何商业化或对外运营宣称，严格定位为技术研究与学习代码。
