# Tutorial series contract

Use this contract when several independently planable and publishable courses form one learning
series. The series document records portfolio-level curriculum facts only. Each course continues to
use its own `course.config.json`, `course-state.json`, outline, lessons, and production lifecycle.

## Workspace layout

```text
<series-root>/
├── README.md
├── course-series.json
├── course-briefs/
│   ├── <course-id>.md
│   └── ...
├── <course-root>/
│   ├── course.config.json
│   ├── course-state.json
│   └── ...
└── ...
```

Course roots may already exist when a series is first brought under this contract. A valid series
plan does not require every future course root to exist. Keep the brief outside the planned course
root so the boundary can be reviewed before `plan-tutorial-course` creates detailed course files.

## README ownership and inheritance

The series-root `README.md` is the single source of truth for learner-facing information that applies
unchanged to every course in the series. During initial planning or migration, compare the existing
course READMEs and promote their genuinely shared facts to the series README. Typical shared facts
include the series purpose, audience baseline, common entry assumptions, teaching method, the meaning
of Core and Extension routes, shared cases, navigation conventions, and common production or viewing
expectations.

A course README links to the series README and records only course-specific information or explicit
deltas: its own promise, audience refinement, additional prerequisites, Core completion outcome,
optional Extension routes, case use, and exceptions to a shared convention. Do not copy the same maintained paragraph or table
into every course README. An exception must name the shared rule it changes; silence inherits the
series rule. Course outlines and lesson cards may restate small learner-facing facts when needed for
navigation or instruction, but they do not become competing sources for shared README policy.

## Series document

```json
{
  "formatVersion": 1,
  "seriesId": "example-series",
  "title": "Example series",
  "contentLanguage": "en",
  "charter": "README.md",
  "outcomes": [
    {
      "id": "SO-01",
      "tier": "graduation",
      "description": "Complete and verify a baseline project."
    },
    {
      "id": "SO-02",
      "tier": "extension",
      "description": "Compare advanced alternatives under new constraints."
    }
  ],
  "courses": [
    {
      "id": "01-core",
      "title": "Core",
      "tier": "graduation",
      "path": "01-core",
      "brief": "course-briefs/01-core.md",
      "requires": [],
      "outcomes": ["SO-01"]
    },
    {
      "id": "02-advanced",
      "title": "Advanced judgment",
      "tier": "extension",
      "path": "02-advanced",
      "brief": "course-briefs/02-advanced.md",
      "requires": [
        {
          "courseId": "01-core",
          "capability": "A verified baseline application and its evidence record."
        }
      ],
      "outcomes": ["SO-02"]
    }
  ],
  "cases": [
    {
      "id": "case-main",
      "title": "Evolving batch processor",
      "purpose": "Expose new operational pressure without changing domains each time.",
      "courses": ["01-core", "02-advanced"]
    }
  ],
  "releaseWaves": [
    { "id": "wave-1", "courses": ["01-core"] },
    { "id": "wave-2", "courses": ["02-advanced"] }
  ]
}
```

`formatVersion`, `seriesId`, `title`, `contentLanguage`, `charter`, `outcomes`, `courses`, and
`releaseWaves` are required. `cases` may be empty or omitted when the series has no meaningful
shared case.

## Identity and paths

Series, outcome, course, case, and wave IDs are stable and unique within their collections. IDs use
letters, digits, dots, underscores, and hyphens, beginning with a letter or digit. Renaming a course
ID is a migration because existing course state, links, and releases may use it.

`charter`, every course `path`, and every course `brief` are series-root-relative, use forward
slashes, and stay within the series root. The charter and briefs must exist as files. A planned
course path may be absent. If it exists, it must be a directory. When that directory contains
`course.config.json`, its `courseId` must match the series course ID. A `course-state.json` without a
course config is invalid. Course roots must not be the series root or nest inside one another, and
series briefs stay outside every course root.

## Outcome and course tiers

Every outcome and course has exactly one series tier:

- `graduation`: part of the minimum series completion promise;
- `extension`: optional depth, transfer, or specialization beyond the minimum series promise.

These values do not replace course-local lesson types. A graduation course may contain both `core`
and `extension` lessons. An extension course also has course-local `core` lessons required to
complete that particular course.

Every outcome must be owned by at least one course, every course must own at least one outcome, and
every graduation outcome must be owned by at least one graduation course.

## Course prerequisites and learning routes

`requires` contains direct prerequisite objects. Each object has exactly the information needed to
explain the edge:

- `courseId`: the prerequisite course;
- `capability`: the observable capability or artifact the later course consumes.

Do not encode sequence-only or redundant transitive edges. A graduation course may depend only on
graduation courses. Extension courses may depend on either tier. The graph must be acyclic.

The series README presents the graph in learner-facing form: courses available at entry, each later
unlocked wave, parallel choices, convergence points, blocked courses with missing capabilities, and
useful stopping points. It also owns the common learner-facing information described above instead
of asking each course README to maintain another copy. Course number is display order only and is
never a substitute for `requires`.

## Shared cases

A case record contains `id`, `title`, `purpose`, and one or more course IDs. Record only cases reused
across meaningful curriculum boundaries or important enough to constrain several courses. A
course-local example remains in that course's outline or brief rather than becoming series state.

The contract does not impose one universal case or a numeric case quota. The human-readable charter
explains why a shared case is reused and when an isolated example is preferable.

## Release waves

Every course appears in exactly one release wave. Wave order is a portfolio plan, not production
state. A course may be placed in the same wave as all of its direct prerequisites or a later wave,
never an earlier one. Course-local production status remains exclusively in `course-state.json`.

Run [`validate-series.mjs`](../scripts/validate-series.mjs) after creating or changing the series
document and before handing a course to detailed planning. Treat its output as structural evidence;
it cannot decide whether the educational boundaries or teaching approach are good.
