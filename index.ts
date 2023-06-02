import { load } from "./js-threads/bridge.js"
import { env, script_path as lib_path } from "./lib.js"

const bytes = await Deno.readFile("zig-out/lib/js-threads-example.wasm");
const wasm = await load(bytes, env, lib_path(), 17, 24);
(wasm.instance.exports.entry_point as Function)();

