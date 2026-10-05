# Writing and learning decisions

## Writing decisions

- **Start from a useful question or result.** Address the learner directly in natural speech, then show how one relevant problem changes as the lesson progresses. Conversational narration improved transfer in three controlled multimedia experiments; this does not justify padding the script with chatty filler [1].
- **Use humor with the lesson's voice.** A wry observation, visual reaction, or playful analogy can make a problem approachable or give the viewer a moment of relief. Keep the idea easy to recover after the joke; revise humor that takes over a crucial explanation or requires unannounced background knowledge. Humor studies have mixed cognitive results [2], and interesting but irrelevant details can hinder learning in some settings [3]. Neither finding requires a humor-free visual style.
- **Do not infer learning from game vocabulary.** A main route, side route, and visible progress may help orientation when they describe the real course. Calling a lesson a level or a quest is only a metaphor. Research on actual game design elements cannot establish that game-like wording improves comprehension; the gamification meta-analysis found heterogeneous effects and no reliable cognitive advantage from game fiction itself [4]. Never promise points, rewards, gates, or competition unless implemented.
- **Give novices guided action and feedback.** Show a small inspectable example, ask for a prediction, demonstrate it, inspect any mismatch, change one thing, and have the learner explain the result when that sequence fits the subject. A PRIMM programming-classroom study found higher post-test performance after a sustained Predict–Run–Investigate–Modify–Make approach, but its school setting and bundled intervention do not isolate any one step or establish the sequence for other domains [5]. Worked-example research also suggests more benefit for novices than experienced learners [6].
- **Use retrieval to check learning.** A post-lesson question should make the learner explain or apply the outcome rather than rate confidence. Testing can improve later retention compared with restudy [7]; the question must still match what this lesson actually taught.

## Design the thinking turn

Before drafting a concept explanation, name the learner's plausible starting idea, the observation
that can test it, the inference the lesson should leave behind, and a nearby situation that would
show whether the learner can use that inference. The starting idea may be an incomplete explanation
or an open question; do not invent a misconception simply to create drama. Use these four notes in
the existing lesson card or storyboard, not as a separate required file or a rigid video formula.
An introduction, reference guide, or straightforward procedure may need a different arc.

For a younger or high-school audience, start with a question they can interpret using their actual
prior knowledge and give them a chance to form an expectation before the decisive observation.
The interest-development model distinguishes a moment that triggers attention from the continued
work of sustaining interest [32]. Chi's framework treats explaining and building an inference as
more active learning work than merely attending to an answer [33]. These are design lenses, not
evidence that every video needs a surprise or an on-screen quiz. In a narrated video, a brief
reflective beat and a later application question can invite thought without claiming that viewers
will pause or answer aloud.
Research on prequestions in authentic university lecture videos found learning gains that were
stronger for the asked material than for unasked material [35]. A field experiment with university
students found that different self-explanation prompt types changed the explanations learners made
but did not significantly change learning outcomes; reported interruptions were associated with
worse outcomes [36]. These studies do not prescribe pacing for a high-school tutorial. Use a
question when it directs attention to the lesson's decisive evidence, and judge its value from the
learner's subsequent explanation rather than from the presence of a prompt alone.

Let humor grow from the problem, expectation, or observable result when the requested voice calls
for it. A light line can acknowledge an intuitive but incomplete idea; the explanation must then
state the literal cause. In two narrated-slideshow experiments, including one with school-age
learners in Germany, relevant humor did better than irrelevant humor on some learning measures, but
did not clearly beat a no-humor control [34]. This supports checking whether a joke helps explain,
not promising that humor raises scores. A visual reaction may add warmth without carrying a claim;
check separately whether learners enjoyed it and whether they can explain the concept.

For example, a lesson about inertia might ask why a loose bag slides forward when a vehicle brakes.
The camera first shows the vehicle and bag moving together, then their positions relative to an
outside reference as the vehicle slows. The spoken explanation distinguishes the bag's temporary
continuation of motion from a supposed forward push; a later shot shows friction slowing the bag.
A brief "the bag is not trying to overtake" line can release tension, but the held comparison and
literal explanation carry the learning. This is an example of the design move, not a prescribed
metaphor, shot order, subject, or claim about the effectiveness of that particular video.

## Further decisions for technical lessons

- **Match guidance to the actual audience.** Identify what learners already know and what is new in this subject, tool, or setting. For an unfamiliar mechanism, introduce only the essential parts and their possible states before showing how they interact [13]. Begin with a complete, inspectable worked example when it suits the task; then ask for one local prediction or missing step before expecting independent construction. Fade help as knowledge grows [14, 15]. These are conditional choices, not a required sequence for every course guide or advanced lesson.
- **Make a repeatable procedure visible.** If a novice must change a material, setting, file, or other input and repeat an action, show where that input is found, what changes, and how the new state produces a result. A visual before/after comparison can explain a conceptual difference but may not teach the physical or digital operation. When a step reuses an earlier result, connect a possible stale output to a skipped update. This is a task-analysis check, not a claim that research establishes one universal demonstration sequence.
- **Ask for an explanation of the mechanism.** Where the lesson includes practice, a useful prompt asks *why* an observed result follows from a particular step or state change. A correct-answer reveal alone is less diagnostic than a prediction compared with observed evidence and a concise explanation of the mismatch. Evidence for induced self-explanation and informative feedback supports the design, but neither meta-analysis proves a universal feedback delay or a fixed number of prompts [16, 17]. In a file-based video course, keep the single static post-lesson question in `lesson.md`; do not insert a forced pause or spoken quiz into `narration.txt`.
- **Animate a change the learner must understand.** A process unfolding, a value moving through a trace, or a route acquiring a capability may warrant motion. Show stable before/after states, preserve the identifiers needed for comparison, and hold the resulting evidence or diagram for inspection. Expressive motion can also set rhythm or tone; the cited learning studies do not measure every creative use of animation. Meta-analyses find a modest average benefit for animation over static pictures, with large variation; a review finds stronger learning benefit when the depicted change is itself the learning target [18–20]. Do not require constant motion or an arbitrary minimum shot length.
- **Let the learner inspect a completed change.** In an experiment with probability animations, pauses improved post-test performance and temporal cues reduced mental effort; they served different functions [25]. When the lesson asks learners to compare steps or states, preserve the relevant prior state or a compact trace after the animation and give the result a useful hold. The experiment does not establish a fixed pause length for tutorials in other domains.
- **Evaluate the whole learning loop.** A visualization should expose a state or relationship the learner could otherwise miss and connect to a prediction, explanation, or usable check. Research on programming instruction finds positive average effects for visualization interventions, but those studies cannot establish the same effect in every narrated tutorial [21]. Check learning with a concrete explanation or transfer task, not watch time, liking, or visual polish alone.
- **Make independent practice inspectable.** After guided examples, a chapter checkpoint and final Core task should ask the learner to act on stated inputs, produce evidence, and compare it with acceptance conditions. Give diagnostic self-check guidance for a likely error, not only a verdict. A review of instructional videos found stronger learning when videos were paired with activities [22], and a feedback meta-analysis found that information content matters [17]. These findings support the design choice; they do not establish that one static question or one task format is sufficient for every learner.

## Audio and visual division of work

- **Audio:** establish the problem, point attention to the relevant part of the frame, explain why a change matters, and connect an observation to the conclusion.
- **Visuals:** hold exact steps, route names, short labels, state changes, comparisons, and results long enough to inspect. A route map or trace can carry detail that would be awkward or dense to read aloud.
- **Together:** present the matching spoken cue and visible state at the same time. Highlight only the part being discussed; reveal a result after a prediction when that order matters. Coordinated narration and pictures, visual signaling, and meaningful segmentation are supported by multimedia research [8–10].
- **Pacing:** divide at a meaningful state or reasoning boundary. Do not reveal the next change before the current one can be inspected. Keep important prior states or a compact trace visible when the learner must compare them. Determine actual holds from the generated audio and a normal-speed readability check, not a universal seconds-per-line formula [10, 18–20].
- **Avoid duplication:** do not turn every spoken sentence into a large on-screen paragraph while also asking the learner to inspect a diagram. Research on redundant spoken and printed text is conditional, but duplicated text can compete with a dynamic visual [8, 11]. Captions remain a selectable accessibility aid, and short labels or exact terms often need to remain visible.
- **Balance persistent elements:** a recurring badge, bar, or ambient animation may establish identity or rhythm as well as orientation. Check it at normal playback size against the evidence, state, or comparison the learner must inspect. Keep expressive elements when they support the viewing experience, and quiet them when they compete for attention or merely repeat player navigation [3, 8–10].
- **Preserve access:** put the meaning of a visual fact needed for the primary outcome in narration. For necessary exact details left on screen, provide learner-facing `## Visual descriptions` in `lesson.md` and include that section near the packaged player and transcript. A verbatim speech transcript alone does not describe visual-only information [12]. This page section is a useful text aid; it is not by itself a claim of audio-description conformance. Check any stated accessibility target against the actual player and media alternatives [12].
