import { dirname, fromFileUrl, join } from "@std/path";
import {
  BaseConfig,
  ConfigArguments,
  ConfigReturn,
} from "@shougo/dpp-vim/config";
import { ExtOptions, Plugin } from "@shougo/dpp-vim/types";
import type {
  Ext as LazyExt,
  LazyMakeStateResult,
  Params as LazyParams,
} from "@shougo/dpp-ext-lazy";
import { flexibleParser, functionParser } from "./lib/parser.ts";
import {
  extractFunctionBody,
  passThrough,
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
          depends: toStringArray(),
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
    const protocols = await args.dpp.getProtocols(args.denops, options);

    const [lazyExt, lazyOptions, lazyParams] = await args.dpp.getExt(
      args.denops,
      options,
      "lazy",
    ) as [LazyExt | undefined, ExtOptions, LazyParams];

    let stateLines: string[] = [];
    if (lazyExt) {
      const lazyResult = await lazyExt.actions.makeState.callback({
        denops: args.denops,
        context,
        options,
        protocols,
        extOptions: lazyOptions,
        extParams: lazyParams,
        actionParams: { plugins },
      }) as LazyMakeStateResult | undefined;
      if (lazyResult) {
        stateLines = lazyResult.stateLines;
      }
    }

    const cacheHome = Deno.env.get("XDG_CACHE_HOME") ??
      join(Deno.env.get("HOME") ?? "~", ".cache");
    const checkFiles = [join(cacheHome, "dpp", "config-sentinel")];

    return { plugins, stateLines, checkFiles };
  }
}
