# Course video style contract

For a file-based course, `video-style.md` at the course root records the visual decisions shared by
its lesson videos. It is an authoring contract, not a learner document or a substitute for each
lesson's storyboard. `design-tutorial` owns the draft and revisions; the existing script-and-preview
review includes the first version, without a separate approval stage.

Record only choices another lesson can apply and a reviewer can recognize:

- course identity and the distinction between elements that stay recognizable and elements that may
  change with the teaching subject;
- typography, color meanings, contrast, and the visual treatment of titles, labels, callouts,
  diagrams, evidence, and authentic application or camera footage when relevant;
- recurring objects or components, transitions, attention cues, and motion behavior that communicate
  the course's tone without competing with demonstrations, exact results, or learner thinking time;
- paths to a few locally viewable reference frames or short clips, with their lesson and draft or
  verified status. Include the different visual situations the course actually uses, such as an
  explanation and a demonstration, rather than treating an introductory montage as the only model.
  Link local references with course-root-relative Markdown paths so the validator can check them.

Use the user's established brand and course choices where present. Do not invent a mandatory
palette, font, layout, illustration style, effect count, or lesson type. A conceptual diagram and a
software demonstration may look different while sharing the same course identity. Real evidence can
retain its authentic appearance inside the course treatment. A reference frame is an example of
the rule, not a template that every shot must repeat.

Before drafting a later lesson, inspect `video-style.md` and the available reference frames or
verified video. Compare representative frames at the intended viewing size, including a handoff
between different lesson types when they exist. Resolve a mismatch by either adapting the new
lesson or recording a deliberate course-wide style revision and checking the affected earlier
lessons. A style-only revision does not alter approved spoken words or require a new WAV. If the
visual revision changes an explanation, evidence, or spoken cue, return to the owning lesson stage.

The course validator can check that a newly recorded draft still has a non-empty style contract. It
cannot certify visual similarity. Human review must judge continuity, readability, and whether the
variation helps the lesson. Existing courses without this file keep their prior records; create the
contract when their visual direction is next revised instead of inventing retroactive approval.
