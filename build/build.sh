#!/usr/bin/env bash
set -e

# Run emconfigure with the normal configure command as an argument.
emcmake cmake ../HiGHS -DOPENMP=OFF -DFAST_BUILD=OFF -DSHARED=OFF

# Run emmake with the normal make to generate wasm object files.
emmake make -j8 libhighs

# Compile the linked code generated by make to JavaScript + WebAssembly.
# 'project.o' should be replaced with the make output for your project, and
# you may need to rename it if it isn't something emcc recognizes
# (for example, it might have a different suffix like 'project.so' or
# 'project.so.1', or no suffix like just 'project' for an executable).
# If the project output is a library, you may need to add your 'main.c' file
# here as well.
# [-Ox] represents build optimisations (discussed in the next section).
emcc -O3 \
	-s EXPORTED_FUNCTIONS="@$(pwd)/exported_functions.json" \
	-s EXTRA_EXPORTED_RUNTIME_METHODS="['ccall']" \
	-s MODULARIZE=1 \
	-fexceptions \
	-flto \
	--closure 1 \
	--pre-js "$(pwd)/../src/pre.js" \
	--post-js "$(pwd)/../src/post.js" \
	lib/*.a -o highs.js
