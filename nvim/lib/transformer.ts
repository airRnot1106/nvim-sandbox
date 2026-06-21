export interface Transformer<T> {
  transform(value: string): T;
}

/**
 * 入力をそのまま出力する Transformer
 */
export function passThrough(): Transformer<string> {
  return { transform: (v) => v };
}

/**
 * `function(...) ... end` リテラルからボディだけを取り出す Transformer
 */
export function extractFunctionBody(): Transformer<string> {
  return {
    transform(v: string): string {
      const afterArgs = v.indexOf(")") + 1;
      const withoutEnd = v.replace(/\s*\bend\b\s*,?\s*$/, "");
      return withoutEnd.slice(afterArgs).trim();
    },
  };
}

/**
 * JSON 文字列を string[] に変換する Transformer
 */
export function toStringArray(): Transformer<string[]> {
  return {
    transform(v: string): string[] {
      try {
        const parsed = JSON.parse(v);
        return Array.isArray(parsed)
          ? parsed.filter((x): x is string => typeof x === "string")
          : [v];
      } catch {
        return [v];
      }
    },
  };
}
