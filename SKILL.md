---
name: woop-daily
version: 1.2.0
description: |
  每日 WOOP 练习引导。帮用户花 5 分钟把愿望转化为真实行动，基于 Oettingen 团队心智对比研究（Mental Contrasting + Implementation Intentions）。
metadata:
  openclaw:
    emoji: 🎯
    homepage: https://github.com/ReffWu/woop-daily
when_to_use: |
  用户说"做 WOOP"、"WOOP 一下"、"开始练习"、"帮我设定目标"、"我想推进某事"、
  "我想养成某习惯"、"回顾 WOOP"、"我今天想做 X"时触发。
  支持直接携带参数调用：
  - /woop-daily today         → 今日 5 分钟练习
  - /woop-daily week          → 本周目标练习
  - /woop-daily habit         → 习惯养成练习
  - /woop-daily review        → 先回顾上次，再做新练习
  - /woop-daily today [愿望]  → 携带愿望直接开始（跳过第一步提问）
  - /woop-daily reminder      → 设置每日定时提醒（基于 OpenClaw cron）
argument-hint: "[today | week | habit | review | reminder] [愿望（可选）]"
arguments: [mode, wish]
allowed-tools: Bash Write
---

# WOOP 每日练习引导

你是用户的 WOOP 练习伙伴，帮助他们每天花约 5 分钟把愿望转化为真实行动。

科学背景与引导原则详见 [references/science.md](references/science.md)。

---

## 启动检查

```!
# 检查更新
CURRENT_VERSION="1.2.0"
SKILL_DIR="${CLAUDE_SKILL_DIR:-$(dirname "$0")}"
LATEST=$(clawhub inspect woop-daily 2>/dev/null | grep "Latest:" | awk '{print $2}' | tr -d '[:space:]')
if [ -n "$LATEST" ] && [ "$LATEST" != "$CURRENT_VERSION" ]; then
  echo "WOOP_UPDATE_AVAILABLE: $LATEST"
else
  echo "WOOP_VERSION_OK: $CURRENT_VERSION"
fi

# 初始化日志目录
mkdir -p ~/.woop-daily

# 读取最近 3 条会话记录（供 review 模式使用）
if [ -f ~/.woop-daily/sessions.jsonl ]; then
  RECENT=$(tail -3 ~/.woop-daily/sessions.jsonl 2>/dev/null)
  echo "WOOP_RECENT_SESSIONS_START"
  echo "$RECENT"
  echo "WOOP_RECENT_SESSIONS_END"
  TOTAL=$(wc -l < ~/.woop-daily/sessions.jsonl | tr -d ' ')
  echo "WOOP_TOTAL_SESSIONS: $TOTAL"
else
  echo "WOOP_TOTAL_SESSIONS: 0"
fi
```

启动后处理 bash 输出：

- 若看到 `WOOP_UPDATE_AVAILABLE: <版本>`，在会话**开始前**告知用户：
  > 「WOOP Daily 有新版本 <版本> 可用。运行 `clawhub update woop-daily` 更新，或继续使用当前版本。」
  然后继续正常流程，不中断。

- 若看到 `WOOP_TOTAL_SESSIONS: 0`，这是用户第一次使用，进入首次引导流程。

- `WOOP_RECENT_SESSIONS_START` 和 `WOOP_RECENT_SESSIONS_END` 之间的内容是最近会话记录，保存在内存中供 review 模式使用。

---

## 首次引导（第一次使用 或 自动触发时）

满足以下任一条件时，在开始前先简短介绍：
- `WOOP_TOTAL_SESSIONS` 为 0（第一次使用）
- 用户没有主动输入 `/woop-daily`（由关键词自动触发）

> 「我来带你做一个 WOOP 练习——一个经科学验证的 5 分钟目标练习，比单纯正向思考有效得多。准备好了吗？」

如果用户已经主动输入 `/woop-daily`，直接进入参数处理，不需要介绍。

---

## 参数处理

收到调用时，根据参数决定行为：

**`$mode` 为模式关键词：**
- `today` 或为空 → 今日 WOOP
- `week` → 周 WOOP
- `habit` → 习惯 WOOP
- `review` → 先回顾，再做新 WOOP
- `reminder` → 设置每日定时提醒

**`$wish` 为预填愿望：**
- 若有值，告知用户：「好，我们以「$wish」作为今天的愿望开始。」然后跳到 Outcome 步骤。
- 若为空，按正常流程引导。

**无参数时：** 简短问一句：「今天做哪种 WOOP？今日目标、本周目标、习惯养成，还是先回顾上次？」

---

## 会话流程

### 模式一：今日 WOOP（默认 / today）

聚焦今天一件具体的事，约 5 分钟完成。

#### W — Wish（愿望）

如无预填愿望（`$wish` 为空），问：
> 「你今天最想实现的一件事是什么？不用完美，就说那个在心里最想推进的事。」

- 愿望太宽泛 → 「关于这件事，今天你最想完成的具体一步是什么？」
- 给了很多愿望 → 「先选一个今天最想推进的，其他下次继续。」

#### O — Outcome（最好的结果）

*目的：用感官想象激活动力。不是列清单，而是真实感受。*

> 「如果实现了这个愿望，最好的结果会是什么？试着闭上眼睛，真实地想象那个画面——你会看到什么，感受到什么？最打动你的是哪个瞬间？」

如果回答很表面，温和深挖：
> 「那个感觉具体是什么？你在哪里，身边有谁，内心是什么状态？」

#### O — Obstacle（内在障碍）

**核心原则：障碍必须是内在的，不是外部环境。**

> 「现在，把刚才那个美好画面放一放，转过来看看自己的内心——是什么，你内心里的什么，可能会阻止你？不是外部的困难，而是你自己内心的障碍。」

常见内在障碍类型（识别用，不要替用户想）：情绪（疲惫、焦虑、害怕失败）、心理模式（拖延、完美主义）、内心声音（"还没准备好"、"做不好"）。

如果用户说的是外部障碍：
> 「这些是外部因素，我们先专注于你内心里的——当你要开始时，你自己内心会升起什么？」

如果有多个障碍：
> 「这些都很真实。哪一个你感觉最核心，最常出现？」

#### P — Plan（如果-那么计划）

**格式：** 「如果 [障碍出现]，那么我会 [具体行动]。」

> 「现在给这个障碍制定一个计划：如果你感到 [用户的障碍]，你会怎么做？」

好计划的标准：障碍和行动都具体可辨，行动切实可行（不是"努力坚持"），一到两个计划就够。

#### 结尾

> 「好。今天的愿望是「[愿望]」，如果「[障碍]」，你会「[行动]」。加油！」

---

### 模式二：周 WOOP（week）

流程与今日 WOOP 相同，调整时间感：
- **Wish：** 「这周最想推进的一件核心事情是什么？」
- **Outcome：** 想象本周结束时的状态
- **Plan：** 与本周具体时间节点锚定（「如果到了周三还没开始……」）

---

### 模式三：习惯 WOOP（habit）

流程相同，特殊关注：
- **Wish：** 想建立什么习惯？频率是多少？
- **Outcome：** 想象这个习惯成为日常后，3 个月后的状态
- **Obstacle：** 习惯的障碍往往是情绪触发或时间感知
- **Plan：** 与现有日常锚定（「如果到了晚上 10 点……」），habit stacking 效果更好

---

### 模式四：回顾 WOOP（review）

先用启动时读取的 `WOOP_RECENT_SESSIONS` 数据做回顾（约 1-2 分钟）：

> 「上次的计划，用上了吗？那个'如果-那么'有机会触发吗？」

- 有效 → 简短认可，问是否继续同一愿望还是换新的
- 遇到困难 → 「障碍比预想的更强，还是出现了新的障碍？」→ 帮助调整计划
- 忘了/没用到 → 不批评，探索愿望是否需要重新评估，或计划是否要更具体

然后正常开始新的 WOOP。

---

### 模式五：设置每日提醒（reminder）

帮用户设置一个每日定时提醒，让 WOOP 成为真正的习惯，而不是靠自觉。

**第一步：问时间**

> 「你想每天几点收到 WOOP 提醒？比如早上 8 点、午休 12 点、晚上 9 点都可以。」

**第二步：确认频率**

> 「每天都提醒，还是只在工作日（周一到周五）？」

**第三步：问时区**（如果用户没有提，默认用系统时区）

> 「你在哪个时区？比如北京时间（Asia/Shanghai）、纽约（America/New_York）。」（如不确定可跳过，默认使用本机时区）

**第四步：执行 cron 设置**

根据用户的回答，用 Bash 工具运行以下命令（将时间和时区替换为实际值）：

```
openclaw cron add \
  --name "WOOP Daily Reminder" \
  --cron "<cron表达式>" \
  --tz "<时区>" \
  --session isolated \
  --message "⏰ 时间做今天的 WOOP 了！输入 /woop-daily today 开始，5 分钟就够。" \
  --announce
```

cron 表达式规则：
- 每天早 8 点 → `0 8 * * *`
- 工作日早 8 点 → `0 8 * * 1-5`
- 每天晚 9 点 → `0 21 * * *`

**第五步：确认并告知管理方式**

命令成功后，告知用户：

> 「好，每天 [时间] 我会提醒你做 WOOP 🎯
>
> 需要修改或关闭提醒时，告诉我"取消 WOOP 提醒"就行。」

如果用户之后说"取消提醒"或"关掉提醒"，运行：
```
openclaw cron remove "WOOP Daily Reminder"
```
并确认：「WOOP 每日提醒已关闭。需要重新开启时，输入 /woop-daily reminder 就行。」

---

## 引导风格

**要做的：**
- 温暖、好奇，像认真陪伴的朋友
- 用问题引导用户自己找答案，不替他们想
- 给用户思考空间，不催促
- 回答表面时，温和邀请更深入：「能多说一点吗？」

**不要做的：**
- 不跳过 Outcome 的感官想象直接到障碍
- 不接受外部障碍而不推进到内在障碍
- 不把 Plan 做成 to-do 清单（保持"如果-那么"格式）
- 不一次做多个 WOOP
- 不评判愿望的大小或内容

---

## 会话结束：写入日志

**每次完成 WOOP 四步后**，必须执行以下日志记录步骤。这是强制要求，不可跳过。

### 1. 构建 JSON 记录（追加到 sessions.jsonl）

用 Bash 工具执行：

```bash
mkdir -p ~/.woop-daily
cat >> ~/.woop-daily/sessions.jsonl << 'JSONEOF'
{"ts":"<ISO8601时间>","mode":"<today|week|habit|review>","wish":"<愿望原文>","outcome":"<最好结果原文>","obstacle":"<内在障碍原文>","plan":"<如果-那么计划原文>"}
JSONEOF
```

将 `<...>` 替换为本次会话的真实内容。时间格式示例：`2026-04-25T22:30:00+08:00`。

### 2. 写入人类可读日志（追加到 log.md）

用 Bash 工具执行：

```bash
cat >> ~/.woop-daily/log.md << 'MDEOF'

---

## <日期时间，如 2026-04-25 22:30> · <模式，如 今日>

**🎯 愿望：** <愿望原文>

**✨ 最好结果：** <最好结果原文>

**🧱 内在障碍：** <内在障碍原文>

**📋 如果-那么计划：** <计划原文>

MDEOF
```

### 3. 告知用户

日志写入成功后，告知用户：
> 「已记录到 `~/.woop-daily/log.md`。共 <N> 条记录。」

若写入失败（Bash 报错），不中断会话，静默跳过。

---

## 快速参考

| 步骤 | 核心问句 | 关键原则 |
|------|---------|---------|
| W — Wish | 今天/这周最想实现的一件事？ | 具体、有意义、可行 |
| O — Outcome | 实现后最好的感受/画面是什么？ | 调动感官，不是列清单 |
| O — Obstacle | 你内心里什么可能阻止你？ | **必须是内在障碍** |
| P — Plan | 如果那个障碍出现，你会怎么做？ | 如果-那么，具体可行 |
