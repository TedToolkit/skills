# TedToolkit Skills

一个 **Agent Skills marketplace**（标准见 [agentskills.io](https://agentskills.io)）——它把团队可复用的技能打包成可安装插件。它不是一个应用，而是一组技能。

目前提供 4 个插件：`tedtoolkit-shared`、`tedtoolkit-annotations`、`tedtoolkit-roslynhelper` 和 `tedtoolkit-project-development`。

`tedtoolkit-project-development` 是原 `tedtoolkit-project-scaffolding` 的后继名称；已安装旧插件的用户需要安装新名称。

---

## 安装

在 Codex 中把本仓库注册为 marketplace，然后安装所需插件：

```
codex plugin marketplace add ./path/to/skills
codex plugin add tedtoolkit-shared@tedtoolkit-skills
```

也可以在 Codex 的插件市场中选择任一插件。安装或更新后，请在新任务中使用，确保新技能被加载。

Claude Code 兼容入口仍保留在 `.claude-plugin/marketplace.json`，但 Codex 使用 `.codex-plugin/marketplace.json` 和每个插件的 `.codex-plugin/plugin.json`。

---

## 前置条件 / 配置

| 项 | 说明 |
| --- | --- |
| .NET 10 SDK | `run-fix`、`merge-default-branch` 的 Release 构建 / 测试需要。 |
| `dotnet format` | 改动 C# 文件后会触发 `dotnet-format-changed.sh`（PostToolUse，best-effort 自动格式化）。 |

---

## 包含的技能

| 技能 | 用途 | 触发示例 |
| --- | --- | --- |
| **`merge-default-branch`** | 安全地把远程默认分支（origin 的 main/master）合并进当前分支：先提交本地改动、fetch、合并、解冲突（不丢功能）、Release 构建验证、按规范提交。 | 「把 main 合并进来」/ "sync my branch with origin/main" |
| **`generate-commit-message`** | 把工作区改动拆成 gitmoji + Conventional Commits 的**原子提交**（一个逻辑改动一个提交），展示计划后批量提交。 | 「帮我拆分提交」/ "commit my changes" |
| **`run-fix`** | 给定一个 .NET 项目名，按类型用对应 Release 命令运行（TUnit test → `dotnet run`，其他 test → `dotnet test`，app → `dotnet run`，library → `dotnet build`），定位失败根因，在你批准后修复、复验转绿、清理掉临时调试代码。 | 「把 Foo.Tests 跑通」/ "build MyApp and make it pass" |
| **`fix-csharp-diagnostics`** | 针对 C# 编译器或分析器诊断做批量修复，定位规则来源、收敛真正违规点，再做最小必要修改。 | 「修一下这些 C# diagnostics」/ "fix these Roslyn warnings" |
| **`tunit-unit-testing`** | 为 TUnit 测试项目补测或整理测试结构，遵循现有断言与夹具风格，避免引入不一致的测试写法。 | 「给这个 TUnit 项目补测试」/ "add tests for this TUnit suite" |
| **`project-scaffolding`** | 按团队约定创建或整理 .NET 仓库、项目边界、文档目录和 `.slnx` 布局。 | 「创建 .NET 解决方案布局」 |
| **`feature-design`** | 在编码前将功能请求整理为可审批的设计、统一术语、验收标准、BehaviorCase 与测试计划。 | 「为退款功能写设计文档」/ "design this feature" |
| **`implement-feature-tdd`** | 基于已批准的功能设计，以小行为切片执行 Red → Green → Refactor。 | 「按这个设计用 TDD 实现功能」/ "implement this approved feature with TDD" |
| **`review-feature-change`** | 只读审查功能改动是否符合设计、BehaviorCase、测试和文档，不执行或修改任何内容。 | 「按设计审查这个功能改动」/ "review this feature change" |
| **`write-readme`** | 为根目录、`.csproj` 项目目录或普通目录编写职责清晰的 README。 | 「补一个项目 README」 |
| **`select-technology`** | 在实现前比较可行方案，基于约束、维护成本与退出路径给出技术选型建议。 | 「帮我为这个功能做技术选型」 |

---

## 怎么用

技能由你的**自然语言意图**自动匹配触发，**不需要记技能名**；当然也可以显式调用。

所有技能都是**门控优先（gate-first）**设计：

> 只读调查 → 给你看计划 / 草稿 → **明确批准** → 才执行写入 / 提交。

这些确认关卡是核心安全设计，写入或提交之前一定会先征求你同意。

---

## 产出风格（House 约定）

- **提交**：gitmoji + Conventional Commits，原子提交。

---

## 贡献者指南

### 仓库结构

```
.claude-plugin/marketplace.json   # Claude Code 市场清单
.codex-plugin/marketplace.json    # Codex 市场清单
plugins/<plugin>/plugin.json      # Claude Code 兼容 manifest
plugins/<plugin>/.codex-plugin/plugin.json # Codex manifest
plugins/<plugin>/skills/<name>/SKILL.md   # 一个技能一个目录
plugins/<plugin>/scripts/*.sh     # 插件级共享 bash 脚本（技能调用）
plugins/<plugin>/hooks/           # 插件级钩子
tests/                            # 自研 Python 评测 harness
```

约定：
- `SKILL.md` 的 `name:` frontmatter **必须等于目录名**（kebab-case）。
- 共享脚本放在 `plugins/<plugin>/scripts/`，SKILL.md 通过 `bash "${CLAUDE_PLUGIN_ROOT}"/scripts/<name>.sh` 调用（单一来源，无需多处同步）。
- 新增插件时，同时登记两份市场清单，并为其提供 Codex manifest。

详见 [`CLAUDE.md`](./CLAUDE.md)。

### 测试

自研 headless harness（**非** pytest/jest）：当前用于 Claude Code 兼容性验证；每个场景在一次性 fixture 里用 `claude -p` 跑技能，再做确定性断言。

```powershell
py -3.13 tests/run_evals.py                               # 全部场景
py -3.13 tests/run_evals.py generate-commit-message      # 单个技能
py -3.13 tests/run_evals.py --filter conflict            # 按子串筛选
py -3.13 tests/run_evals.py --keep                       # 保留工作目录便于调试
py -3.13 tests/run_evals.py --judge                      # 额外用 LLM 评分
```

需要：Python 3.13+（含 `pyyaml`）、`claude`、`git`、`bash`、.NET 10 SDK。每次运行有真实 API 花费、每场景约 30s–3min。断言 schema 与更多细节见 [`tests/README.md`](./tests/README.md)。
