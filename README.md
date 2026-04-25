# WOOP Daily — Claude Skill

> 基于 Gabriele Oettingen 团队 20 余年科学研究的每日目标实现练习，每天 5 分钟，对话式引导。

## 什么是 WOOP？

WOOP（Wish · Outcome · Obstacle · Plan）是纽约大学心理学教授 Gabriele Oettingen 开发的**心智对比**方法，结合了两项经过大量实验验证的技术：

- **Mental Contrasting（心智对比）**：先鲜活想象最好结果，再诚实面对内在障碍。这个"对比"动作激发真实的行动必要感，而非普通的正向思考。
- **Implementation Intentions（执行意图）**：用"如果-那么"格式制定计划，让大脑预演应对障碍，行动趋于自动化。

**研究数据：**
- 运动量提升 2 倍（vs. 单纯信息组，持续 4 个月）
- 学习时间 4.3h vs 1.5h（vs. 普通目标设定，住院医生 RCT）
- 有效领域：减重、戒烟、学业、人际、疼痛管理、习惯养成

## 功能

| 命令 | 功能 |
|------|------|
| `/woop-daily` | 交互式选择模式，开始练习 |
| `/woop-daily today` | 今日 5 分钟 WOOP |
| `/woop-daily week` | 本周目标 WOOP |
| `/woop-daily habit` | 习惯养成 WOOP |
| `/woop-daily review` | 先回顾上次，再做新练习 |
| `/woop-daily today 早睡` | 携带愿望直接开始，跳过第一步提问 |

Claude 也会根据上下文**自动触发**（无需输入 `/`），当你说"我想推进某事"、"帮我设定目标"、"做个 WOOP"时。

## 安装

### 方式一：直接下载 .skill 文件（Cowork）

1. 从 [Releases](../../releases) 下载最新的 `woop-daily.skill`
2. 双击文件，Cowork 自动安装

### 方式二：手动安装（Claude Code）

```bash
# 个人 skill（所有项目可用）
mkdir -p ~/.claude/skills/woop-daily
curl -o ~/.claude/skills/woop-daily/SKILL.md \
  https://raw.githubusercontent.com/reffwu/woop-daily/main/SKILL.md

# 或者 clone 整个仓库
git clone https://github.com/reffwu/woop-daily.git ~/.claude/skills/woop-daily
```

### 方式三：项目级 skill

```bash
# 仅在当前项目可用
mkdir -p .claude/skills/woop-daily
cp SKILL.md .claude/skills/woop-daily/
```

## 使用示例

```
你：/woop-daily today

Claude：好，开始今日 WOOP 练习。你今天最想实现的一件事是什么？

你：把那篇文章的初稿写完

Claude：如果你完成了这篇初稿，最好的结果会是什么？试着想象完成那一刻——你会看到什么，感受到什么？

你：感觉终于卸下了一块石头，可以轻松地去做别的事

Claude：很好。现在，把那个轻松的感觉放一放，转过来看看自己的内心——你内心里，什么可能会阻止你今天动笔？

你：我总是会想"还没准备好"，一直拖着不开始

Claude：好，现在给这个障碍制定一个计划：如果你又冒出"还没准备好"的念头，你会怎么做？

你：如果我又觉得"没准备好"，那么我就先只写开头的一段，不管质量

Claude：很好。今天的 WOOP：愿望「把文章初稿写完」，如果「觉得没准备好」，你会「先只写开头一段」。加油！
```

## Skill 设计原则

这个 skill 的引导逻辑完全基于原始研究：

- **Obstacle 步骤必须是内在障碍**：外部环境很难控制，内心障碍才能被真正面对和计划
- **Outcome 使用感官想象**：不是列清单，而是调动感受——这是心智对比发挥作用的关键
- **期望值感知**：如果你对某个愿望信心很低，WOOP 帮你明智放弃，而不是强迫你硬撑
- **一次只做一个 WOOP**：聚焦比多多益善更有效

## 理论基础

| 概念 | 描述 |
|------|------|
| Mental Contrasting | Oettingen (2000)，三种思维模式：Indulging / Dwelling / Mental Contrasting |
| Implementation Intentions | Gollwitzer (1999)，If-Then 计划的神经科学基础 |
| MCII | Mental Contrasting + Implementation Intentions，两者结合效果最优 |
| Expectancy Moderation | 期望值调节效果，低期望时帮助明智放弃 |

## 参考文献

- Oettingen, G. (2014). *Rethinking Positive Thinking: Inside the New Science of Motivation.* Current/Penguin.
- Oettingen, G., & Gollwitzer, P. M. (2010). Strategies of setting and implementing goals. In J. E. Maddux & J. P. Tangney (Eds.), *Social psychological foundations of clinical psychology.*
- Frontiers in Psychology (2021). A Meta-Analysis of the Effects of Mental Contrasting With Implementation Intentions on Goal Attainment.
- [woopmylife.org](https://woopmylife.org) — Official WOOP practice resource

## License

MIT
