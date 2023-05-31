submodule:
	git submodule init
	git submodule update --remote

run:
	zig build
	deno run --allow-read index.ts
