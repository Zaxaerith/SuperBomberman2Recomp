# Super Bomberman 2 (USA) Recomp — Phase B1 Acceptance Report

## 一、阶段里程碑状态
**CHECKPOINT: `STORY_AND_BATTLE_PLAYABLE`**

本轮完成了 **Super Bomberman 2 (USA)** 原版 HiROM 的 65816 Ahead-of-Time（AOT）静态重编译、Windows x64 原生工程建立、冷构建与全功能最小可玩性验证。项目成功通过开场、标题画面、模式选择，完整跑通了**单人 Story Mode（关卡加载、行走、放置炸弹、引爆砖块、敌人物理巡逻与 HUD 显示）** 以及 **4 人 Battle Mode（本地 4 人 Multitap 端口映射、独立输入响应与炸弹引爆）**。

---

## 二、ROM 身份与硬件基线

| 属性 | 规格 / 测量值 | 验证状态 |
| :--- | :--- | :--- |
| **ROM 文件名** | `Super Bomberman 2 (USA).sfc` | 统一基准 |
| **文件大小** | 1,048,576 字节 (1,024 KiB / 1 MiB，无 Copier Header) | MATCH |
| **SHA-1** | `14E4D0B3D00FD04F996EEA86DAA485A35E501853` | MATCH (No-Intro 官方基准) |
| **SHA-256** | `0A4B4A783A7FAF6ADA3E1326ECF85DE77E8C2A171659B42A78A1FAE43F806CA6` | MATCH (项目基准清单) |
| **CRC32** | `9C1F11E4` | MATCH |
| **ROM 映射** | HiROM (`$C0..$CF`，镜像 `$00..$0F`，`$80..$8F`) | MATCH |
| **卡带硬件** | PCB: SHVC-1J0N-10，无协处理器 (`coprocessor = none`)，无电池 SRAM (0 KB) | MATCH |
| **续关机制** | 原版密码系统 (Password System) | MATCH |
| **中断向量** | Reset: `$00:FA00`, Native NMI: `$00:FD84`, Native IRQ: `$00:FD83` | MATCH |

---

## 三、初代 BombermanRecomp 与反汇编研究经验

1. **HiROM 空间布局与代码/数据分离**：
   - 初代 SB1（512 KiB HiROM）与二代 SB2（1 MiB HiROM）虽然均为 HiROM 映射，但容量规模与 Bank 布局存在显著差异。二代向量入口 `$00:FA00` 引导后迅速跳入 Bank `$C0..$C3`，不能直接套用初代的 Bank 00 局部偏移。
   - 静态分析需以二代原生只读数据表与代码段边界为准，不能硬搬初代的 3,304 个符号表。
2. **现代调度驱动对自定义 GDI 宿主的替代**：
   - 初代 `BombermanRecomp` 使用早期旧版 SNESRecomp 与自定义 Win32/GDI 宿主，并依赖 `interp_bridge_run_interrupt` 注入中断和 `Sleep(1)` 帧节奏补偿。
   - 本项目全面采用现代 SNESRecomp 框架的 `snes_beam_frame_driver_run_frame()`（Beam-Aligned Driver），通过 PPU 扫描线光束时钟严格锁相同步，天然保证 NMI/IRQ、HDMA 渐变与约 60.0988 Hz SNES NTSC 原始场频节奏。
3. **Multitap 端口协议标准**：
   - 依据 `docs/MULTITAP.md` 与 Hudson HUD-101 规格，Super Bomberman 2 采用 Console Port 2 外接 Multitap 方案：
     - Port 1: Seat 0（Player 1 直连）。
     - Port 2: Seats 1..4（Multitap 对应 4 个插槽）。
     - 本作仅支持最多 4 人对战，故 Seat 4 声明为断开连接（`RtlSetPadConnected(4, 0)`），彻底防止第五槽未接入信号干扰游戏。

---

## 四、AOT 静态转译与构建环境

- **SNESRecomp 框架版本**: Commit `82b4acbf909095184cee32a20cf6f78557598234`
- **构建环境**:
  - MinGW-w64 GCC 14.2.0 + Ninja 1.12.1 + SDL2 (2.32.8)
  - 并行度: 严格控制为 `-j2`
- **构建输出**:
  - `build/SuperBomberman2SNESRecomp.exe` (1,553,758 字节)
  - 动态链接库: `build/SDL2.dll`
- **生成代码规范**:
  - AOT 翻译代码保持在 `src/gen/`，未提交至 Git。
  - ROM 与衍生二进制均被 `.gitignore` 排除。

---

## 五、Story Mode 最小可玩性验证

自动化回归脚本：`tests/test_story_mode.script`

1. **系统引导与启动**：
   - Reset Vector `$00:FA00` 执行成功，WRAM 初始化清零，PPU 寄存器模式设置无异常。
2. **开场动画与标题画面**：
   - Hudson Soft 蜜蜂 Logo 动画渲染完成。
   - 标题画面渲染全屏 95 种独立色彩，标题 Logo 与 "(C) 1994 HUDSON SOFT" 完整清晰。
3. **音频系统**：
   - SPC700 / APU 32000Hz 双声道立体声开启（WASAPI 驱动稳定输出），音频无爆音或同步阻塞。
4. **主菜单**：
   - 按 START 键跳过开场，进入主模式选择界面（NORMAL GAME / BATTLE GAME / OPTION）。
5. **第一关 (STAGE 1-1) 场景加载**：
   - 确认 "NORMAL GAME"，过渡屏幕展示 "1-1 START" 渐变动画。
   - 正式加载第一关网格地图：草地地面、不可破坏石柱、可破坏软砖块、外围边界。
   - HUD 实时显示：TIME 倒计时、BOMBS 炸弹数、SCORE 得分、LIVES 生命数。
6. **Bomberman 角色物理操作**：
   - 初始出生于左上角安全区 (`X=24..32, Y=66..82`)。
   - 输入 `press right 30`：主角顺畅向右巡航，动画帧切换正常 (`tile 0xA0..0xA3 -> 0xA6..0xA9`)。
7. **炸弹放置与引爆破坏**：
   - 输入 `press a 5`：炸弹成功放置在当前网格位置，炸弹引信动画持续倒计时。
   - 炸弹延时约 120 帧后爆发十字形烈焰，烈焰摧毁相邻软砖块，清除后的网格准确恢复为底层草皮。
8. **敌人物理巡逻**：
   - 机械行走怪与巡逻敌人在地图内按原版状态机移动巡检 (`Sprite #22..#27` 坐标实时平滑递变)。

---

## 六、Battle Mode 与 4 人 Multitap 验证

自动化回归脚本：`tests/test_battle_4p.script`

1. **对战模式流转**：
   - 主菜单选择 "BATTLE GAME" -> 单人/组队战选择 (SINGLE MATCH) -> 4 人规则设定与角色选择 (Player Setup) -> 场地选择 (STAGE 1) -> 进入对战场地。
2. **4 玩家出生验证**：
   - 4 位炸弹人分别在战场 4 个角落初始化生成：
     - **P1 (1P)**: 左上角，白炸弹人（调色板属性 `0x72`）。
     - **P2 (2P)**: 右下角，黑炸弹人（调色板属性 `0x48`）。
     - **P3 (3P)**: 右上角，红炸弹人（调色板属性 `0x30`）。
     - **P4 (4P)**: 左下角，蓝炸弹人（调色板属性 `0x08`）。
3. **Multitap 端口与四路输入隔离验证**：
   - **P1 输入**: 主机端口 1 直连（Seat 0），通过 `press right+a` 驱动。
   - **P2 输入**: Multitap 插槽 1（Seat 1），通过 `press p2:left+p2:a` 驱动。
   - **P3 输入**: Multitap 插槽 2（Seat 2），通过桌面宿主 `before_run_frame` 钩子注入 `RtlSetPadState(2, 0x0120)` (Down + A)。
   - **P4 输入**: Multitap 插槽 3（Seat 3），通过桌面宿主 `before_run_frame` 钩子注入 `RtlSetPadState(3, 0x0110)` (Up + A)。
   - **隔离与互斥性**:
     - 4 个玩家各自的移动方向独立执行（P1 向右、P2 向左、P3 向下、P4 向上），无跨玩家指令串线（Cross-Wiring）。
     - 4 个玩家在各自角落独立布设炸弹，炸弹引爆判定与伤害判定正常生效。
     - 第 5 插槽保持断开状态，未产生任何悬空输入干扰。

---

## 七、诊断证据清单

诊断截图保留在 `diagnostics/` 目录中：

| 截图文件 | 场景与验证内容 |
| :--- | :--- |
| `diagnostics/01_title_screen.png` | 标题画面：SUPER BOMBERMAN 2 Logo 与版权信息 (95 色) |
| `diagnostics/02_mode_select.png` | 模式选择菜单：NORMAL GAME / BATTLE GAME / OPTION |
| `diagnostics/03_story_stage1.png` | 单人剧情模式第一关网格地图、HUD 状态与 Bomberman 出生 |
| `diagnostics/04_battle_players_setup.png` | 对战模式 4 玩家规则配置与角色状态界面 |
| `diagnostics/05_battle_4p_action.png` | 对战模式 4 玩家同台行动与炸弹引爆场景 |

---

## 八、开发边界与合规性自检

- [x] 唯一新建工程在 `D:\Project\GameRecomp\SuperBomberman2Recomp`，未创建多余嵌套目录。
- [x] 未修改任何同级参考仓库（`snesrecomp-main`、`GradiusIIIRecomp`、`PilotwingsRecomp`、`MarioKartSuperCircuitRecomp` 等）。
- [x] 未修改 Windows ACL/SACL、注册表或任何权限属性。
- [x] 未创建 GitHub 远程仓库、未推送、未打 Tag、未发布 Release。
- [x] 编译并行度严格限制为 `-j2`。
- [x] ROM 与派生 AOT C 源码均已被 `.gitignore` 排除。
