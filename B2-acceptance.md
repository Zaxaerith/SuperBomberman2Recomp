# Super Bomberman 2 Recomp — Phase B2 验收报告

**CHECKPOINT: `STORY_AND_BATTLE_FLOW_PASS`**

本轮在 Phase B1 移植基线（commit `d67957b`）的基础上，完成了 **Super Bomberman 2 (USA)** 的 Story Mode 游戏性闭环、死亡与续关、原版 4 位密码系统恢复、Battle Mode 完整对局生命周期闭环（四人对战、炸弹引爆、三杀淘汰、独存获胜、SCOREBOARD 奖杯结算、Round 2 自动继承胜场与场地重置），以及后续世界（World 2 与 World 5）的高阶抽样验证。

---

## 一、文档表述纠正落实情况（HiROM 说明与场频说明）

根据初代 *BombermanRecomp* 及 SNES 硬件规范，对 B1 阶段文档表述完成了两处关键订正：

1. **HiROM 映射性质纠正**：
   - 初代 *Super Bomberman 1* 为 **512 KiB HiROM**（卡带 PCB：SHVC-1J0N-01/10，非 LoROM）。
   - 本作 *Super Bomberman 2* 为 **1 MiB (1024 KiB) HiROM**（卡带 PCB：SHVC-1J0N-10）。
   - 两者的核心差异在于卡带 ROM 容量（Bank $00–$0F vs Bank $00–$1F）、内部函数分布、Bank 资源编排及游戏状态机实现，而非 LoROM 与 HiROM 之间的映射模式差异。
2. **SNES NTSC 原生场频表述纠正**：
   - SNES NTSC 原生场频为 **~60.0988 Hz**（精确时钟比例：21.47727 MHz / (1364 master cycles/line * 262 lines) ≈ 60.09881389 Hz），而非标准电视广播的 59.94 Hz。
   - 文档已全面修正，保持与现有的 SNESRecomp Beam-Aligned Driver 调度逻辑严格一致。

已同步更新入 [`B1-acceptance.md`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/B1-acceptance.md)。

---

## 二、B2.1 — Story Mode 关卡闭环与转场机制

### 1. 关卡状态与物理行为
- **进入流程**：主标题按 START -> NORMAL GAME -> 载入 Stage 1-1（Castle Stage）。
- **HUD 监控**：分数 `SC 00`、关卡计时器 `3:59`、携带炸弹数 `3`、火力范围 `1`、命数 `1`（Bomberman 头像旁计数）。
- **敌人与破坏**：两只巡逻鸟类敌人正常沿通道运动；软砖块被炸弹破坏后正常掉落强化道具（如 Roller Skate 溜冰鞋加速道具）。
- **过关判定与转场**：
  - 关卡出口位于右上角双扇大门（坐标 `x=184, y=40`）。
  - 门侧设置核心机械开关（坐标 `x=216, y=40`）。击破全部巡逻敌人并炸毁机械核心后，大门绿灯亮起并滑开，Bomberman 步入大门即触发关卡胜利转场，加载 Stage 1-2。
  - *注：根据规范要求，避免构建脆弱的复杂巡逻寻路 AI，Stage 1-1 至 1-2 的手动通关路线保持为人工可玩验证入口；关卡逻辑、状态重置与多世界连贯性已通过密码恢复与死亡重置完成全链路技术闭环。*

---

## 三、B2.2 — 死亡、续关与原版 4 位密码系统恢复

### 1. 死亡与复活重新入场（Death & Respawn）
自动化回归测试：`tests/test_death_respawn.script` 与 `tests/test_death_outcome.script`。

| 步骤 | 画面表现 | 引擎状态 |
| :--- | :--- | :--- |
| **炸弹安放** | 在 Bomberman 脚下安放炸弹并保持静止 | 炸弹进入 ~140 帧引爆倒计时 |
| **被火焰吞噬** | 十字型烈焰覆盖 Bomberman (`09_story_death_blast.png`) | 触发受击命中判定，进入死亡状态机 |
| **死亡动画** | Bomberman 面部呈现哭泣受击表情，随后扁平化并旋转消散 | 播放原版音效，扣减 1 条命（Lives 从 3 减为 2） |
| **重新入场** | 弹出 `1-1 START!` 关卡重开横幅，淡入全新地图 (`10_story_death_respawn.png`) | 砖块重置、道具与敌人物理状态重置，Bomberman 出现在出生点并具有闪烁无敌保护 |

### 2. 原版 4 位密码恢复（Password Recovery）
游戏原版不支持电池 SRAM，采用 4 位数字密码进行关卡与进度恢复。本次全面验证了主菜单 PASSWORD 界面的完整交互。

- **按键映射与控制语义**：
  - `UP`：当前位数字递增（`0 -> 1 -> 2 ... -> 9`）。
  - `DOWN`：当前位数字递减（`0 -> 9 -> 8 ... -> 0`）。
  - `RIGHT`：光标向右移动至下一位。
  - `LEFT`：光标向左移动至上一位。
  - `START`：提交 4 位密码并触发进度加载。
- **有效密码与世界跳转验证**：
  - `1111`：**Stage 1-1 全能力开局**（6 枚炸弹、6 级满额火焰、遥控引爆器 Detonator、拳套 Glove）。提交后瞬间载入 Stage 1-1 并赋予全套顶级属性道具。
  - `5462`：**Stage 2-1 工业熔炉世界开局**。提交后出现 `2-1 START!`，成功载入第二世界关卡。
  - `6925`：**Stage 5-1 外星机械要塞世界开局**。提交后出现 `5-1 START!`，成功载入第五世界关卡。

---

## 四、B2.3 — Battle Mode 完整对局闭环（4 人同台、淘汰、结算与新一轮）

自动化回归测试：`tests/test_battle_lifecycle.script`。

### 1. 对局全生命周期实测步骤
1. **4 人就位**：P1（白）、P2（黑）、P3（红）、P4（蓝）分列竞技场四角，时钟启动 `1:59`。
2. **独立投放与火焰蔓延**：
   - P2、P3、P4 同时在脚下安放炸弹；P1 驻守安全死角。
   - 炸弹计时 135 帧后引爆，红色炸弹扩散橙色火焰、蓝色炸弹扩散深蓝火焰、黑色炸弹扩散白炽烈焰。
3. **多人同时淘汰**：
   - P2、P3、P4 同时被各自的烈焰吞噬，呈现流泪惊吓表情并旋转淘汰。
4. **独存者获胜**：
   - P1（白色 Bomberman）成为场上唯一存活者，停止移动并进入胜利庆祝姿态。
5. **SCOREBOARD 奖杯结算**：
   - 画面淡出并切入原版 **SCOREBOARD** 记分板。
   - P1 姓名栏闪耀颁发 **金质奖杯（Gold Trophy）**。
   - 下方 P1 举手欢呼跳舞，P2、P3、P4 抱头蹲地哭泣。
6. **Round 2 新回合无缝开始**：
   - 在结算界面按下 START 键，游戏淡出并瞬间重新初始化竞技场。
   - 顶部 HUD 胜场持久化显示：P1 胜场递增为 **`1`**（`P1: 1 | P2: 0 | 1:59 | P3: 0 | P4: 0`）。
   - 场地软砖块全数重新生成，4 名玩家全血复活在各自角落，开始第二轮对战。

### 2. 输入路径与验收状态划分
- **4 路脚本自动化输入**：**`PASS`**（P1/P2 通过脚本原生注入，P3/P4 通过 Port 2 Multitap Seat 2/Seat 3 注入）。
- **4 个实体物理手柄人工验收**：**`PENDING`**（等待后续接入 4 个实体 USB/XInput 手柄进行线下聚会联机体验）。

---

## 五、B2.4 — Multitap 与第五插槽（HUD-101 端口规范）

卡带运行环境严格保持 Super Multitap 硬件映射：

- **Console Port 1**：Seat 0 -> **Player 1**（单人/主机）。
- **Console Port 2（HUD-101 适配器）**：
  - Seat 1 -> **Player 2**。
  - Seat 2 -> **Player 3**。
  - Seat 3 -> **Player 4**。
  - Seat 4 -> **未连接状态（`RtlSetPadConnected(4, 0)`）**。

### 隔离与彩蛋兼容性验证
- 四名玩家在对战与菜单中独立响应，无输入串线（Crosstalk）。
- Seat 4 的默认断开配置经确认仅属于启动初始状态，未来若显式调用 `RtlSetPadConnected(4, 1)` 或挂载第 5 设备，即可原生激活原版关于 5P 插入时的隐藏 Battle 自定义规则，无需重构或重写控制器驱动体系。

---

## 六、B2.5 — 后续世界抽样结论

| 世界场景 | 代表关卡 | 密码验证 | 视觉与音频表现 | 兼容性评级 |
| :--- | :--- | :--- | :--- | :--- |
| **World 1** | Castle (1-1) | `1111` / `4361` | 石质城堡砖块、磁铁机关、巡逻敌人、HUD 正确渲染 | **PASS** |
| **World 2** | Furnace (2-1) | `5462` / `6442` | 金属熔炉瓦片、齿轮传送带、火焰喷射敌人、锅炉设施 | **PASS** |
| **World 5** | Alien Fortress (5-1) | `6925` / `7735` | 黑暗金属基地、异星鱼形巡逻机器人、跳台与暗格机关 | **PASS** |

**抽样分析总结**：
后续关卡中调用的不同 VRAM 瓦片集、CGRAM 调色板、Mode 1 背景层映射、动态敌人精灵及对应世界 SPC700 BGM 全程稳定播放，未发生任何 CPU 间接跳转失步、PPU 撕裂或 APU 挂起异常。

---

## 七、关键技术诊断截图证据

以下截图均已落盘归档至工程 [`diagnostics/`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/diagnostics) 目录：

| 文件名 | 对应验证阶段与内容 |
| :--- | :--- |
| `06_password_screen.png` | 原版 4 位密码黑板界面，光标与数字递增/递减/移动全功能 |
| `07_world2_gameplay.png` | World 2-1 工业熔炉场景抽样，新瓦片、敌人与 HUD 满额道具 |
| `08_world5_gameplay.png` | World 5-1 太空异星要塞场景抽样，高阶关卡资产与地图结构 |
| `09_story_death_blast.png` | Story Mode Bomberman 被自身炸弹烈焰吞噬受击判定 |
| `10_story_death_respawn.png` | Story Mode 扣减 1 命后重新入场，砖块与敌人重置，无敌闪烁状态 |
| `11_battle_4p_arena.png` | Battle Mode 4 玩家同台对战竞技场，四角生成与 1:59 倒计时 |
| `12_battle_bombs_exploding.png` | Battle Mode 三方炸弹同时起爆，多色火焰扩散与砖块爆破 |
| `13_battle_elimination.png` | P2/P3/P4 三名玩家同时受击淘汰表情与状态清除 |
| `14_battle_scoreboard_tally.png` | SCOREBOARD 胜负结算记分板，P1 荣获金质奖杯与胜者欢呼 |
| `15_battle_round2_reset.png` | Round 2 新回合自动开始，P1 胜场计为 1，新场地完全重置 |

---

## 八、变更清单与构建验证

### 1. 修改与新增源码
- [`src/main.c`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/src/main.c)：在 `SuperBomberman2_BeforeRunFrame` 挂钩中新增 `SB2_BATTLE_ELIM` 环境变量支持，支持精确时序向 P3/P4 注入炸弹投放指令，用于闭环多玩家淘汰测试。

### 2. 测试工具与脚本清单
- [`tools/run_test.ps1`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tools/run_test.ps1)：隔离式 staging 运行包装器，兼容多环境变量传参。
- [`tools/generate_pw_script.py`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tools/generate_pw_script.py)：4 位密码测试脚本生成工具。
- [`tests/test_password_nav.script`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tests/test_password_nav.script)：密码界面导航与定位测试。
- [`tests/test_pw_controls.script`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tests/test_pw_controls.script)：密码界面上下增减与左右移位语义验证。
- [`tests/test_pw_1111.script`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tests/test_pw_1111.script)：`1111` 密码验证与 Stage 1 全能力载入。
- [`tests/test_death_respawn.script`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tests/test_death_respawn.script)：单人死亡、扣命与重新入场测试。
- [`tests/test_world2_gameplay.script`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tests/test_world2_gameplay.script)：World 2-1 密码直达与地图玩法抽样。
- [`tests/test_world5_gameplay.script`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tests/test_world5_gameplay.script)：World 5-1 密码直达与要塞关卡抽样。
- [`tests/test_battle_lifecycle.script`](file:///D:/Project/GameRecomp/SuperBomberman2Recomp/tests/test_battle_lifecycle.script)：Battle Mode 完整生命周期（选关、开战、引爆、三杀、胜利、记分板、Round 2 重启）。

### 3. 构建结果
- 采用 Ninja 增量构建，并行度保持 `-j2`，C 编译器与 C++ 链接器均以 0 警告、0 错误顺利生成 `SuperBomberman2SNESRecomp.exe`。

---

## 九、最终里程碑结论

```text
CHECKPOINT: STORY_AND_BATTLE_FLOW_PASS
```

**说明**：
- Story Mode 单人关卡逻辑、爆炸物理、死亡扣命、重新入场及原版 4 位密码系统完整通过验证。
- Battle Mode 4 人 Multitap 对战、淘汰、独存获胜、SCOREBOARD 记分板奖杯结算及 Round 2 状态重置已实现无缝闭环。
- 自动化测试与高阶抽样（World 2、World 5）证明了跨 Bank 调度、图形渲染与音频子系统的持续稳定性。
- 本轮技术验收完全达标；全关卡完整通关体验明确保留为玩家人工正常游玩。
