import assert from "node:assert/strict";
import test from "node:test";

import {
  lintHtmlVisualStyle,
  lintScriptVisualStyle,
} from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/visual-source-lint.mjs";

test("shot placement and deterministic motion stay local", () => {
  assert.doesNotThrow(() => lintHtmlVisualStyle(
    '<style>.shot { position: absolute; transform: translateX(2px); opacity: .8; }</style>' +
    '<section style="left: 2rem; width: 50%; --motion-phase: 1"></section>', "scene.html"));
  assert.doesNotThrow(() => lintScriptVisualStyle(
    'node.style.transform = "translateX(2px)"; node.style.setProperty("opacity", "0.8");', "motion.js"));
});

test("inline HTML cannot redefine shared typography and palette", () => {
  assert.throws(() => lintHtmlVisualStyle('<section style="font-family: Other; left: 2px"></section>', "scene.html"),
    /overrides shared visual property font-family/);
  assert.throws(() => lintHtmlVisualStyle('<style>.shot { background: red; }</style>', "scene.html"),
    /overrides shared visual property background/);
  assert.throws(() => lintHtmlVisualStyle('<style>@import "other.css";</style>', "scene.html"),
    /shared CSS imports and fonts/);
});

test("scripts cannot inject visual CSS while motion writes remain available", () => {
  assert.throws(() => lintScriptVisualStyle('node.style.color = "red";', "scene.js"),
    /overrides shared visual property color/);
  assert.throws(() => lintScriptVisualStyle('node.style.setProperty("font-size", "40px");', "scene.js"),
    /unapproved style property/);
  assert.throws(() => lintScriptVisualStyle('node.style.setProperty(variableName, value);', "scene.js"),
    /unapproved style property/);
  assert.throws(() => lintScriptVisualStyle('document.createElement("style")', "scene.js"),
    /injects an unreviewed stylesheet/);
  assert.throws(() => lintScriptVisualStyle('element.setAttribute("style", "color: red")', "scene.js"),
    /injects an unreviewed stylesheet/);
});
