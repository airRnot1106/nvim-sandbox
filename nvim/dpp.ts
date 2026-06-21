import { dirname, fromFileUrl, join } from "@std/path";
import {
  BaseConfig,
  ConfigArguments,
  ConfigReturn,
} from "@shougo/dpp-vim/config";
import { Plugin } from "@shougo/dpp-vim/types";
import { flexibleParser, functionParser } from "./lib/parser.ts";
import {
  extractFunctionBody,
  passThrough,
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
          lua_add: extractFunctionBody(),
          lua_source: extractFunctionBody(),
        },
      );

      const plugin = await builder.build(source);

      plugins.push(plugin);
    }

    return { plugins };
  }
}
