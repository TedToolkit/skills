const LOCAL_STYLE_PROPERTIES = new Set([
  "display", "position", "inset", "inset-block", "inset-inline", "top", "right", "bottom", "left",
  "width", "height", "min-width", "max-width", "min-height", "max-height", "aspect-ratio",
  "margin", "margin-top", "margin-right", "margin-bottom", "margin-left",
  "padding", "padding-top", "padding-right", "padding-bottom", "padding-left",
  "grid", "grid-area", "grid-column", "grid-row", "grid-template-columns", "grid-template-rows",
  "flex", "flex-direction", "flex-grow", "flex-shrink", "flex-basis", "flex-wrap",
  "align-items", "align-self", "justify-content", "justify-self", "place-items", "place-content",
  "gap", "row-gap", "column-gap", "order", "z-index", "overflow", "overflow-x", "overflow-y",
  "transform", "transform-origin", "translate", "rotate", "scale", "opacity", "visibility",
  "clip-path", "pointer-events", "object-position", "will-change", "text-align",
  "animation", "animation-name", "animation-duration", "animation-delay", "animation-timing-function",
  "animation-fill-mode", "animation-iteration-count", "animation-direction", "animation-play-state",
  "transition", "transition-property", "transition-duration", "transition-delay", "transition-timing-function",
]);

function cssName(name) {
  return name.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`).toLowerCase();
}

function allowedLocalProperty(name) {
  const property = cssName(name);
  return LOCAL_STYLE_PROPERTIES.has(property) || property.startsWith("--motion-");
}

function checkDeclarations(css, source) {
  const clean = css.replace(/\/\*[\s\S]*?\*\//g, "");
  if (/@(?:import|font-face)\b/i.test(clean)) {
    throw new Error(`editable composition keeps shared CSS imports and fonts out of local styles: ${source}`);
  }
  for (const match of clean.matchAll(/(?:^|[;{])\s*(--[\w-]+|[a-z][\w-]*)\s*:/gi)) {
    if (!allowedLocalProperty(match[1])) {
      throw new Error(`editable composition local style overrides shared visual property ${match[1]}: ${source}`);
    }
  }
}

export function lintScriptVisualStyle(script, source) {
  const clean = script;
  if (/\b(?:createElement\s*\(\s*["'`]style["'`]|new\s+CSSStyleSheet\b|adoptedStyleSheets\b|\.insertRule\s*\(|\.cssText\s*=|\.setAttribute\s*\(\s*["'`]style["'`]|<style\b)/i.test(clean) ||
      /Object\.assign\s*\(\s*[^,]+\.style\s*,/i.test(clean) || /\.style\s*=/i.test(clean) ||
      /\b(?:eval\s*\(|new\s+Function\s*\(|style\s*=\s*\{\s*\{)/i.test(clean) ||
      /\[\s*["'`]style["'`]\s*\]\s*(?:\.|\[|=)/i.test(clean) ||
      /["'`][^"'`\r\n]*\.css(?:[?#][^"'`\r\n]*)?["'`]/i.test(clean)) {
    throw new Error(`editable composition script injects an unreviewed stylesheet or style text: ${source}`);
  }
  for (const match of clean.matchAll(/\.style\.([A-Za-z][A-Za-z0-9]*)\s*(?:=|\+=|-=)/g)) {
    if (!allowedLocalProperty(match[1])) {
      throw new Error(`editable composition script overrides shared visual property ${match[1]}: ${source}`);
    }
  }
  for (const match of clean.matchAll(/\.style\[\s*([^\]]+)\s*\]\s*(?:=|\+=|-=)/g)) {
    const literal = /^(?:"([^"]+)"|'([^']+)')$/.exec(match[1].trim());
    if (!literal || !allowedLocalProperty(literal[1] ?? literal[2])) {
      throw new Error(`editable composition script writes an unapproved style property: ${source}`);
    }
  }
  for (const match of clean.matchAll(/\.style\.setProperty\s*\(\s*([^,)]+)/g)) {
    const literal = /^(?:"([^"]+)"|'([^']+)')$/.exec(match[1].trim());
    if (!literal || !allowedLocalProperty(literal[1] ?? literal[2])) {
      throw new Error(`editable composition script writes an unapproved style property: ${source}`);
    }
  }
}

export function lintHtmlVisualStyle(html, source) {
  const clean = html.replace(/<!--[\s\S]*?-->/g, "");
  for (const match of clean.matchAll(/<style\b[^>]*>([\s\S]*?)<\/style\s*>/gi)) {
    checkDeclarations(match[1], source);
  }
  const outsideScriptsAndStyles = clean
    .replace(/<script\b[^>]*>[\s\S]*?<\/script\s*>/gi, "")
    .replace(/<style\b[^>]*>[\s\S]*?<\/style\s*>/gi, "");
  const styleAttributes = [...outsideScriptsAndStyles.matchAll(/\sstyle\s*=\s*(?:"([^"]*)"|'([^']*)')/gi)];
  if ([...outsideScriptsAndStyles.matchAll(/\sstyle\s*=/gi)].length !== styleAttributes.length) {
    throw new Error(`editable composition needs quoted local style declarations: ${source}`);
  }
  for (const match of styleAttributes) {
    checkDeclarations(match[1] ?? match[2], source);
  }
  for (const match of clean.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script\s*>/gi)) {
    lintScriptVisualStyle(match[1], source);
  }
}
