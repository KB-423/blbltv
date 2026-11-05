# PiliPala (Bilibili) 待接入接口清单与 TV 大屏规划

> **文档定位**：整理自 `third/lib/http/api.dart` 及相关网络层实现，对比当前 `bili_tv` 架构后提炼出未实现的接口资产，按 TV 大屏（10-foot UI、遥控器导航、大屏视听体验）的实用价值进行优先级分级，作为后续功能演进与接口实现的长期 Backlog。

---

## 一、 P0 级：全屏播放与视听核心（大屏观影质感）

直接决定播放器的沉浸度、互动性与长视频/连续剧观看体验。

| 业务分类 | API 接口名称 | 端点地址 | 请求方式 | 关键入参 | TV 大屏落地场景与产品价值 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **选集与分P** | 视频分 P 列表 / 选集 | `/x/player/pagelist` | GET | `bvid` 或 `aid` | 电视剧、纪录片、长合集等呼出底部/右侧**选集网格**，遥控器左右键快速切集。 |
| **番剧视频流** | PGC 番剧专用播放流 | `/pgc/player/web/playurl` | GET (Wbi) | `bvid`, `cid`, `qn`, `fnval=4048` | 大会员/正版番剧专属播放流（普通 Web 接口无法播放 PGC 视频）。 |
| **弹幕流** | Web 端 Proto 弹幕分段 | `/x/v2/dm/web/seg.so` | GET | `type=1`, `oid (cid)`, `segment_index` | 大屏观影的核心灵魂；配合 Canvas 实现 60fps 平滑弹幕滚屏与密度调节。 |
| **在线人数** | 正在观看人数统计 | `/x/player/online/total` | GET | `aid`, `cid`, `bvid` | 在控制栏顶部显示 “XX人正在看”，营造大屏影院级氛围。 |
| **一键三连** | 一键点赞/投币/收藏 | `/x/v2/view/like/triple` | POST | `bvid`, `csrf` | 控制栏提供三连按钮，或遥控器**长按 OK 键呼出三连能量环动效**。 |
| **点赞状态** | 查询是否已点赞 | `/x/web-interface/archive/has/like` | GET | `bvid` | 唤起控制栏时实时高亮或置灰点赞图标。 |
| **点赞操作** | 视频点赞 / 取消赞 | `/x/web-interface/archive/like` | POST | `bvid`, `like=1/2`, `csrf` | 遥控器单次点击切换点赞状态。 |
| **投币状态** | 查询是否已投币 | `/x/web-interface/archive/coins` | GET | `bvid` | 控制栏显示已投币枚数（0/1/2 枚）。 |
| **投币操作** | 视频投币 | `/x/web-interface/coin/add` | POST | `bvid`, `multiply=1/2`, `select_like=1` | 呼出投币弹窗选择 1 币或 2 币。 |
| **收藏夹投放** | 将视频加入/移出收藏夹 | `/x/v3/fav/resource/deal` | POST | `rid (aid)`, `type=2`, `add_media_ids`, `del_media_ids` | 遥控器呼出用户收藏夹列表多选打钩。 |
| **外挂字幕** | 视频 AI / CC 字幕 | `/x/player/wbi/v2` | GET (Wbi) | `aid`, `cid` | 提取中英外挂 SRT/VTT 字幕，在画质面板中提供字幕开关与字号调整。 |

---

## 二、 P1 级：激活侧边导航栏专区（填充空页面）

将当前处于静态占位或开发中的 TV 侧边栏各主要板块彻底盘活。

### 1. 热门专区 (`features/popular`)
- **端点**：`/x/web-interface/popular`（综合热门流）
- **入参**：`pn` (页码), `ps` (每页条数)
- **排行端点**：`/x/web-interface/ranking/v2`（全站日榜、周榜、入站必看）
- **入参**：`rid` (分区 id, 0 为全站), `type=all`
- **TV 落地**：4 列卡片瀑布流，顶部提供二级分类标签（全站热门、每周必看、入站必看、排行榜）。

### 2. 直播专区 (`features/live`)
- **端点**：`https://api.live.bilibili.com/xlive/web-interface/v1/index/getList`（直播大厅首页与分区）
- **直播详情与流**：`https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo`
  - 入参：`room_id`, `protocol=0,1`, `format=0,1,2`, `codec=0,1`, `qn=10000`
- **TV 落地**：大屏呈现网游、手游、单机、娱乐、虚拟主播分类，遥控器直达直播全屏起播，支持低延迟 HTTP-FLV / HLS 切换。

### 3. 番剧与影视专区 (`features/bangumi`)
- **端点**：
  - 季度索引：`/pgc/season/index/result?season_type=1&pagesize=20&order=3`
  - 剧集详情：`/pgc/view/web/season` (传入 `season_id` 或 `ep_id`)
- **TV 落地**：横版海报墙布局，展示正在热播、新番时间表、国创、电影、电视剧分类。

---

## 三、 P2 级：视频延展与深度消费（辅助大屏体验）

1. **相关视频推荐 (`Api.relatedList`)**
   - **端点**：`/x/web-interface/archive/related`
   - **TV 落地**：视频播放结束时，在大屏中央自动弹出 3 张相关联的高清推荐卡片，5 秒内无操作自动连播下一个。
2. **轻量只读评论区 (`Api.replyList`)**
   - **端点**：`/x/v2/reply/main`（主评论）、`/x/v2/reply/reply`（楼中楼）
   - **TV 落地**：遥控器按下键或菜单键呼出半屏透明毛玻璃抽屉，仅供遥控器上下翻阅热评与神评，支持点赞，不做繁琐文字输入。
3. **UP 主空间与合集系列 (`Api.memberArchive`, `Api.getMemberSeasonsAndSeriesApi`)**
   - **端点**：
     - 投稿视频：`/x/space/wbi/arc/search?mid=xxx`
     - 合集与系列：`/x/polymer/web-space/seasons_series_list?mid=xxx`
     - 关注关系修改：`/x/relation/modify` (关注/取关)
   - **TV 落地**：在播放器或卡片中点击 UP 主卡片，进入 UP 主大屏主页，一键浏览 UP 主全部合集与代表作。
4. **稍后再看管理 (`Api.seeYouLater`, `Api.toViewLater`, `Api.toViewDel`)**
   - **端点**：`/x/v2/history/toview`
   - **TV 落地**：收纳进个人中心 Tab，支持首页卡片长按“加入稍后再看”。
5. **搜索输入实时联想 (`Api.searchSuggest`)**
   - **端点**：`https://s.search.bilibili.com/main/suggest?term=xxx`
   - **TV 落地**：用户在输入框键入拼音或字符时，下方实时弹出 6~8 条补全候选词，减少遥控器拼写成本。

---

## 四、 P3 级：移动端专属/不适合大屏交互的接口（建议直接裁剪）

大屏场景坚决摒弃复杂手机端逻辑，保持 TV 客户端的轻快纯粹：

- **密码与短信验证码登录**：TV 端必须坚持免密扫码登录，杜绝遥控器输入账号密码与滑块验证码。
- **私信聊天会话 (`sessionList`, `sessionMsg`, `sendMsg`)**：TV 端几乎无私聊即时通讯需求。
- **系统消息与 @ 通知 (`msgFeedReply`, `msgFeedAt`)**：通知繁杂且破坏大屏沉浸感。
- **动态图文流与转发 (`memberOpus`, `followDynamic`)**：B 站图文动态格式混杂，在大屏上排版体验极差。
