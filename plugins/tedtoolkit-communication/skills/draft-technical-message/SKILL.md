---
name: draft-technical-message
description: >-
  Draft or revise technical messages for colleagues, maintainers, or vendors. Use for asking
  someone for technical help, describing observed problems, checking interface usage, or turning
  investigation findings into a concise message or email. Default to a humble inquiry about the
  sender's usage or understanding, preserve verified facts, and include only what the recipient
  needs to understand, reproduce, or answer the request. Produces drafts; independent debugging,
  formal issue records, and sending messages are separate tasks.
---

# Draft Technical Message

Turn supplied technical facts and a communication goal into a message the recipient can understand
and act on. Default to one concise, ready-to-send plain-text draft in the language appropriate to
the user and recipient. The English language of these instructions does not determine the draft's
language. Honor the user's requested format, length, and tone.

## Gather enough context

Identify the recipient, relationship, requested help, and available inputs, actions, results, and
supporting materials from the conversation and user-selected sources. Reuse known information.
Use a natural generic greeting when a name is missing; ask a focused question only when missing
information would materially change the message's meaning.

Read the relevant portions of referenced chats or files with available tools before relying on
them. Historical execution results are existing evidence; do not claim to have rerun or verified
them in the current drafting task. Do not expand drafting into debugging, code changes, or building
a reproduction package. Note essential missing materials outside the draft when needed.

## Filter information for the recipient

Determine which component the recipient owns, which interfaces they know, and what they need to
answer. For each detail, ask whether omitting it would hinder understanding, reproduction, or a
useful answer. Omit it by default when it would not.

- Describe the situation through interfaces, objects, and terms the recipient recognizes. For
  component maintainers, prioritize their component, public calls, inputs, and observed outputs.
- Omit internal project names, wrappers, package management, dependency sources, local paths, and
  investigation history unless they affect reproduction or diagnosis. Explain their relevance
  when included. A wrapper may matter to its maintainer while adding no value to an upstream author.
- Use a component version, API version, or build identifier the recipient can recognize. A local
  wrapper's package version is not automatically the upstream component's version. If the supplied
  identifier is insufficient, note what is missing outside the draft instead of inventing one.
- Keep essential inputs, observations, location identifiers, and the request in the message.
  Put extensive logs and comparison runs in supporting materials, or reserve them for follow-up.
  Preserve relevant evidence without internal names, for example: "I also see the same result
  when calling the public interface directly."

Retain conditions and limitations that change the meaning of the problem. Concision must not
remove essential parameters, failure conditions, or established facts.

## Start with the sender's usage and understanding

Default to a humble request to check the sender's integration, parameter interpretation, input
requirements, or handling of results, even when evidence points toward the recipient's implementation.

- Open naturally: "I would appreciate your guidance on a result I am not sure how to handle."
- Invite clarification: "Could you help me check whether I am missing an input requirement or
  misunderstanding how this interface should be used?"
- Prefer neutral subjects such as "my call," "the response I received," or "these output values."
  Avoid assigning responsibility through phrases such as "your broken implementation."
- Replace "Why does your interface report success but return invalid data?" with a factual
  observation followed by a request: "The call reports success, and I see these values in the
  response. Could you advise how I should interpret or handle them?"
- For an already confirmed implementation issue, ask about a supported workaround or a suitable
  version rather than repeatedly proving who is responsible.

Keep humility in the interpretation and request while stating observations clearly. Treat a
possible usage mistake as a question, not an invented admission of fault. Do not weaken verified
observations into guesses, conceal relevant evidence, or contradict a confirmed cause to sound
polite. Avoid accusatory or rhetorical questions and demands for an explanation. Use respectful,
natural language without repeated apologies, self-deprecation, or excessive ceremony.

## Make the facts concrete and the request answerable

Select facts around the communication goal rather than reproducing the full investigation:

- Include the relevant scenario, inputs, and call sequence. Preserve selected function names,
  parameter values, units, index conventions, and versions exactly as supported by evidence.
- Distinguish observed behavior, stated expectations, and causes awaiting confirmation. Do not
  infer that every output is valid merely because a call reports success.
- Cite only supplied execution or inspection results. Do not invent logs, attachments, versions,
  test conclusions, or commitments to a fix.
- Describe comparison runs as "I also tried ..., and still see the same result," without turning
  them into a claim that every possible usage problem has been ruled out.
- Distinguish "I can provide," "I have prepared," and "I have attached." A local file's existence
  does not mean the recipient has received it.
- Close with a specific request about input preparation, parameter choices, result interpretation,
  a supported handling strategy, or recommended usage.

Use a natural flow: reason for asking, essential calls and observations, and the help requested.
Combine these in short messages; use a few numbered items or an email subject when useful. Do not
force a fixed template or provide multiple styles or writing commentary by default.

For an illustration of tone and recipient filtering, read the
[generic inquiry example](references/technical-inquiry-example.md) when useful. Its fictional
details are examples, never evidence for a user's project.

## Check the draft before delivery

Confirm the recipient can tell what the sender did, what was observed, and which help is requested.
Check that the concise version retains essential technical facts, starts from the sender's usage
or understanding, and does not invent fault. Remove unnecessary internal names, dependency sources,
and investigation history while preserving reproduction conditions.

Unless the user requests explanation or comparison, return the draft directly. Keep any necessary
evidence-gap note outside it. Drafting does not authorize sending a message, publishing an issue,
or making commitments on the user's behalf; perform those actions only when separately requested.
