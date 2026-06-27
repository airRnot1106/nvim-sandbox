import { dirname, fromFileUrl, join } from "@std/path";
import {
  BaseConfig,
  ConfigArguments,
  ConfigReturn,
} from "@shougo/dpp-vim/config";
import { Plugin } from "@shougo/dpp-vim/types";
import type { LazyMakeStateResult } from "@shougo/dpp-ext-lazy";
import { flexibleParser, functionParser } from "./lib/parser.ts";
import {
  extractFunctionBody,
  passThrough,
  toBoolean,
  toJsonValue,
  toStringArray,
} from "./lib/transformer.ts";
import { createPluginBuilder } from "./lib/builder.ts";

const configDir = dirname(fromFileUrl(import.meta.url));
const pluginsDir = join(configDir, "plugins");

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<ConfigReturn> {
    args.contextBuilder.setGlobal({
      protocols: ["git"],
      extParams: {
        installer: {
          minCommitDays: 7,
          maxInactiveDays: 180,
        },
      },
    });

    const plugins: Plugin[] = [];

    for await (const entry of Deno.readDir(pluginsDir)) {
      if (!entry.name.endsWith(".lua")) continue;
      const filePath = join(pluginsDir, entry.name);
      const source = await Deno.readTextFile(filePath);

      const builder = createPluginBuilder(
        [flexibleParser(args.denops, filePath), functionParser()],
        {
          name: passThrough(),
          repo: passThrough(),
          rev: passThrough(),
          depends: toStringArray(),
          lazy: toBoolean(),
          on_cmd: toJsonValue(),
          on_event: toJsonValue(),
          on_ft: toJsonValue(),
          on_map: toJsonValue(),
          lua_add: extractFunctionBody(),
          lua_source: extractFunctionBody(),
        },
      );

      const plugin = await builder.build(source);

      plugins.push(plugin);
    }

    const [context, options] = await args.contextBuilder.get(args.denops);

    const lazyResult = await args.dpp.extAction(
      args.denops,
      context,
      options,
      "lazy",
      "makeState",
      { plugins },
    ) as LazyMakeStateResult | undefined;
    const stateLines = lazyResult?.stateLines ?? [];

    const cacheHome = Deno.env.get("XDG_CACHE_HOME") ??
      join(Deno.env.get("HOME") ?? "~", ".cache");
    const checkFiles = [join(cacheHome, "dpp", "config-sentinel")];

    return { plugins, stateLines, checkFiles };
  }
}
