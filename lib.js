import { import_zig_string } from "./js-threads/bridge.js"
export const env = { __print, __print_number }

/**
 * 
 * @param {number} ptr 
 * @param {number} len 
 */
function __print (ptr, len) {
    console.log(import_zig_string(ptr, len))
}

/**
 * 
 * @param {number} n 
 */
function __print_number (n) {
    console.log(n)
}

/// Extracts current script file path from artificially generated stack trace
export function script_path() {
    try {
        throw new Error();
    } catch (e) {
        let parts = e.stack.match(/(?:\(|@)(\S+):\d+:\d+/);
        return parts[1];
    }
}
