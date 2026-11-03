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
| **路由导航** | `go_router: ^18.1.2` | 声明式路由管理。使用 `ShellRoute` 承载 TV 左侧导轨，全屏播放器使用独立 Root 路由。 |
| **数据建模** | `freezed: ^4.0.3` + `json_serializable` | 不可变数据模型，自动实现 `copyWith`、`fromJson`/`toJson` 与深层对比。 |
| **网络层** | `dio: ^5.11.1` + `cookie_jar: ^4.0.9` | 统一会话管理、Cookie 持久化、Wbi 请求签名拦截器、Buvid 设备标识、防盗链 Referer 注入。 |
| **持久化** | `shared_preferences: ^2.5.6` | 轻量化本地偏好与会话存储，通过 Riverpod 统一注入。 |
| **代码生成** | `build_runner: ^2.17.1` | 自动生成 `.freezed.dart` 与 `.g.dart`。 |
| **TV 交互** | `dpad: ^3.1.1` | **统一且必须使用 `dpad` 库** 处理 TV 遥控器与焦点，**严禁自行手写 tvfocus**。 |

---

## 2. 遥控器与大屏焦点核心准则 (`dpad`)

项目已引入专门的大屏焦点库 `package:dpad/dpad.dart`，**所有 TV 交互必须严格遵守以下规范，严禁自行手写 Focus/InkWell 轮子**：

### 2.1 根组件挂载
在 `MaterialApp.router` 或 `MaterialApp` 中通过 `builder` 挂载 `Dpad.wrap()`：

```dart
MaterialApp.router(
  routerConfig: router,
  builder: Dpad.wrap(), // 必需：安装 D-pad 核心引擎与按键监听
)
```

### 2.2 可聚焦组件规范
所有需要被遥控器落焦与点击的组件，**一律使用 `DpadFocusable` 包裹**：

```dart
import 'package:dpad/dpad.dart';

DpadFocusable(
  autofocus: true, // 可选：进入页面默认落焦
  onSelect: () {   // 遥控器 OK / 确定键响应
    context.push('/player/BVxxxx');
  },
  child: VideoCard(video),
)
```

- **按键响应**：确定事件使用 `onSelect`，长按（如呼出菜单）使用 `onLongSelect`。
- **区域管理**：列表或网格使用 `DpadRegion` 保持焦点记忆（`DpadEnterBehavior`）。
- **动效与主题**：高亮边框、缩放与阴影优先使用 `dpad` 自带的 `DpadTheme` 与 `DpadEffect` 机制。

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
2. **防盗链 Header**：
   请求 B 站图片与视频流时，必须在 Header 中附加：
   - `Referer: https://www.bilibili.com`
   - `User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ...`
3. **免密码 TV 扫码登录**：
   TV 场景坚决摒弃账号密码输入框。使用 `/x/passport-login/web/qrcode/generate` 并在大屏渲染高清二维码，后台轮询 `/x/passport-login/web/qrcode/poll`，成功后提取 Cookie 存入 `cookie_jar`。

---

## 5. 项目目录结构规范

```text
lib/
├── core/                           # 基础设施与全局公用能力
│   ├── constants/                  # API 常量与尺寸配置 (api_constants.dart, app_constants.dart)
│   ├── network/                    # 网络客户端与拦截器 (api_client.dart, api_response.dart)
│   ├── storage/                    # 本地数据持久化 (storage_service.dart)
│   ├── theme/                      # TV 暗色主题与色盘 (tv_theme.dart)
│   └── utils/                      # Wbi 签名、计数/时长格式化 (wbi_signer.dart, formatters.dart)
│
├── models/                         # 领域实体模型 (全部使用 Freezed 声明)
│   ├── common/                     # 通用包装类 (api_response_model.dart 等)
│   ├── user/                       # 用户数据模型 (user_info_model.dart)
│   └── video/                      # 视频与卡片数据模型 (video_item_model.dart)
│       └── generated/              # 由 build_runner 生成的 .freezed.dart 和 .g.dart
│
├── widgets/                        # TV 专用核心基础控件
│   ├── tv_scaffold.dart            # 大屏防切边脚手架
│   ├── tv_image.dart               # 带防盗链 Referer 的图片组件
│   └── tv_status_view.dart         # 大屏加载中、错误重试与空状态
│
├── router/                         # 路由配置
│   ├── route_paths.dart            # 路由静态常量
│   └── app_router.dart             # GoRouter 配置（ShellRoute 承载侧边导轨）
│
├── features/                       # 业务功能模块 (按 Feature 划分，避免一次性生成全量未验证代码)
│   ├── main/                       # TV 外壳容器与左侧导航导轨 (tv_main_shell.dart, tv_nav_rail.dart)
│   ├── home/                       # 首页推荐流 (screens/, providers/, repositories/, widgets/)
│   ├── popular/                    # 热门专区
│   ├── live/                       # 直播专区
│   ├── bangumi/                    # 追番与影视
│   ├── search/                     # 大屏检索（T9/首字母键盘）
│   ├── player/                     # TV 视频播放器核心
│   ├── user/                       # 个人中心与扫码登录
│   └── settings/                   # 播放设置与系统设置
│
└── main.dart                       # 应用程序统一入口
```

---

## 6. Agent 编码质量与自检清单 (Verification Checklist)

Agent 在每次提交代码变更或完成任务前，必须执行以下自检：

- [ ] **不要自己写 tvfocus**：是否全部采用 `dpad` (`DpadFocusable`、`DpadRegion`、`Dpad.wrap()`)？
- [ ] **避免全量代码堆砌**：保持项目架构骨架精炼，逐步迭代，不做过度设计。
- [ ] **代码生成校验**：是否运行了 `dart run build_runner build` 并确保所有生成文件（`generated/*.freezed.dart`, `generated/*.g.dart`）正常同步。
- [ ] **静态分析无报错**：运行 `flutter analyze` 或确认无严重警告与编译错误。
- [ ] **网络安全**：请求图片与视频时是否附加了 `Referer` 与合规 `User-Agent`？
- [ ] **状态管理纯粹性**：是否使用 Riverpod 管理状态？是否杜绝了状态与视图强耦合？
- [ ] **保持非商业合规**：代码与注释严禁包含任何商业化或对外运营宣称，严格定位为技术研究与学习代码。
