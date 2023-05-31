import { load, import_zig_string } from "./js-threads/bridge.js"

const bytes = await Deno.readFile("zig-out/lib/js-threads-example.wasm");
const wasm = await load(bytes, { __print });
(wasm.instance.exports.entry_point as Function)();

function __print (ptr: number, len: number) {
    console.log(import_zig_string(ptr, len))
}
