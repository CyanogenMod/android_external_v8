LOCAL_CPP_EXTENSION := .cc

LOCAL_SRC_FILES := \
	src/accessors.cc \
	src/allocation-site-scopes.cc \
	src/allocation-tracker.cc \
	src/allocation.cc \
	src/api.cc \
	src/arguments.cc \
	src/assembler.cc \
	src/assert-scope.cc \
	src/ast-value-factory.cc \
	src/ast.cc \
	src/background-parsing-task.cc \
	src/bailout-reason.cc \
	src/base/bits.cc \
	src/base/cpu.cc \
	src/base/division-by-constant.cc \
	src/base/logging.cc \
	src/base/once.cc \
	src/base/platform/condition-variable.cc \
	src/base/platform/mutex.cc \
	src/base/platform/semaphore.cc \
	src/base/platform/time.cc \
	src/base/sys-info.cc \
	src/base/utils/random-number-generator.cc \
	src/bignum-dtoa.cc \
	src/bignum.cc \
	src/bootstrapper.cc \
	src/builtins.cc \
	src/cached-powers.cc \
	src/checks.cc \
	src/code-factory.cc \
	src/code-stubs-hydrogen.cc \
	src/code-stubs.cc \
	src/codegen.cc \
	src/compilation-cache.cc \
	src/compiler.cc \
	src/compiler/access-builder.cc \
	src/compiler/ast-graph-builder.cc \
	src/compiler/change-lowering.cc \
	src/compiler/code-generator.cc \
	src/compiler/common-operator.cc \
	src/compiler/control-builders.cc \
	src/compiler/gap-resolver.cc \
	src/compiler/graph-builder.cc \
	src/compiler/graph-reducer.cc \
	src/compiler/graph-replay.cc \
	src/compiler/graph-visualizer.cc \
	src/compiler/graph.cc \
	src/compiler/instruction-selector.cc \
	src/compiler/instruction.cc \
	src/compiler/js-builtin-reducer.cc \
	src/compiler/js-context-specialization.cc \
	src/compiler/js-generic-lowering.cc \
	src/compiler/js-graph.cc \
	src/compiler/js-inlining.cc \
	src/compiler/js-typed-lowering.cc \
	src/compiler/linkage.cc \
	src/compiler/machine-operator-reducer.cc \
	src/compiler/machine-operator.cc \
	src/compiler/machine-type.cc \
	src/compiler/node-cache.cc \
	src/compiler/node.cc \
	src/compiler/operator.cc \
	src/compiler/pipeline.cc \
	src/compiler/raw-machine-assembler.cc \
	src/compiler/register-allocator.cc \
	src/compiler/schedule.cc \
	src/compiler/scheduler.cc \
	src/compiler/simplified-lowering.cc \
	src/compiler/simplified-operator-reducer.cc \
	src/compiler/simplified-operator.cc \
	src/compiler/source-position.cc \
	src/compiler/typer.cc \
	src/compiler/value-numbering-reducer.cc \
	src/compiler/verifier.cc \
	src/contexts.cc \
	src/conversions.cc \
	src/counters.cc \
	src/cpu-profiler.cc \
	src/data-flow.cc \
	src/date.cc \
	src/dateparser.cc \
	src/debug.cc \
	src/deoptimizer.cc \
	src/disassembler.cc \
	src/diy-fp.cc \
	src/dtoa.cc \
	src/elements-kind.cc \
	src/elements.cc \
	src/execution.cc \
	src/extensions/externalize-string-extension.cc \
	src/extensions/free-buffer-extension.cc \
	src/extensions/gc-extension.cc \
	src/extensions/statistics-extension.cc \
	src/extensions/trigger-failure-extension.cc \
	src/factory.cc \
	src/fast-dtoa.cc \
	src/fixed-dtoa.cc \
	src/flags.cc \
	src/frames.cc \
	src/full-codegen.cc \
	src/func-name-inferrer.cc \
	src/generator.js \
	src/global-handles.cc \
	src/handles.cc \
	src/heap-profiler.cc \
	src/heap-snapshot-generator.cc \
	src/heap/gc-idle-time-handler.cc \
	src/heap/gc-tracer.cc \
	src/heap/heap.cc \
	src/heap/incremental-marking.cc \
	src/heap/mark-compact.cc \
	src/heap/objects-visiting.cc \
	src/heap/spaces.cc \
	src/heap/store-buffer.cc \
	src/heap/sweeper-thread.cc \
	src/hydrogen-bce.cc \
	src/hydrogen-bch.cc \
	src/hydrogen-canonicalize.cc \
	src/hydrogen-check-elimination.cc \
	src/hydrogen-dce.cc \
	src/hydrogen-dehoist.cc \
	src/hydrogen-environment-liveness.cc \
	src/hydrogen-escape-analysis.cc \
	src/hydrogen-gvn.cc \
	src/hydrogen-infer-representation.cc \
	src/hydrogen-infer-types.cc \
	src/hydrogen-instructions.cc \
	src/hydrogen-load-elimination.cc \
	src/hydrogen-mark-deoptimize.cc \
	src/hydrogen-mark-unreachable.cc \
	src/hydrogen-osr.cc \
	src/hydrogen-range-analysis.cc \
	src/hydrogen-redundant-phi.cc \
	src/hydrogen-removable-simulates.cc \
	src/hydrogen-representation-changes.cc \
	src/hydrogen-sce.cc \
	src/hydrogen-store-elimination.cc \
	src/hydrogen-types.cc \
	src/hydrogen-uint32-analysis.cc \
	src/hydrogen.cc \
	src/i18n.cc \
	src/ic/access-compiler.cc \
	src/ic/call-optimization.cc \
	src/ic/handler-compiler.cc \
	src/ic/ic-compiler.cc \
	src/ic/ic-state.cc \
	src/ic/ic.cc \
	src/ic/stub-cache.cc \
	src/icu_util.cc \
	src/interface-descriptors.cc \
	src/interface.cc \
	src/interpreter-irregexp.cc \
	src/isolate.cc \
	src/jsregexp.cc \
	src/libplatform/default-platform.cc \
	src/libplatform/task-queue.cc \
	src/libplatform/worker-thread.cc \
	src/lithium-allocator.cc \
	src/lithium-codegen.cc \
	src/lithium.cc \
	src/liveedit.cc \
	src/log-utils.cc \
	src/log.cc \
	src/lookup.cc \
	src/messages.cc \
	src/objects.cc \
	src/optimizing-compiler-thread.cc \
	src/ostreams.cc \
	src/parser.cc \
	src/perf-jit.cc \
	src/preparse-data.cc \
	src/preparser.cc \
	src/profile-generator.cc \
	src/property.cc \
	src/regexp-macro-assembler-irregexp.cc \
	src/regexp-macro-assembler.cc \
	src/regexp-stack.cc \
	src/rewriter.cc \
	src/runtime-profiler.cc \
	src/runtime.cc \
	src/safepoint-table.cc \
	src/sampler.cc \
	src/scanner-character-streams.cc \
	src/scanner.cc \
	src/scopeinfo.cc \
	src/scopes.cc \
	src/serialize.cc \
	src/snapshot-common.cc \
	src/snapshot-source-sink.cc \
	src/string-search.cc \
	src/string-stream.cc \
	src/strtod.cc \
	src/token.cc \
	src/transitions.cc \
	src/type-feedback-vector.cc \
	src/type-info.cc \
	src/types.cc \
	src/typing.cc \
	src/unicode.cc \
	src/utils.cc \
	src/v8.cc \
	src/v8threads.cc \
	src/variables.cc \
	src/version.cc \
	src/zone.cc

LOCAL_SRC_FILES += \
	third_party/fdlibm/fdlibm.cc

v8_local_src_files_arm := \
		src/arm/assembler-arm.cc \
		src/arm/builtins-arm.cc \
		src/arm/code-stubs-arm.cc \
		src/arm/codegen-arm.cc \
		src/arm/constants-arm.cc \
		src/arm/cpu-arm.cc \
		src/arm/debug-arm.cc \
		src/arm/deoptimizer-arm.cc \
		src/arm/disasm-arm.cc \
		src/arm/frames-arm.cc \
		src/arm/full-codegen-arm.cc \
		src/arm/interface-descriptors-arm.cc \
		src/arm/lithium-arm.cc \
		src/arm/lithium-codegen-arm.cc \
		src/arm/lithium-gap-resolver-arm.cc \
		src/arm/macro-assembler-arm.cc \
		src/arm/regexp-macro-assembler-arm.cc \
		src/arm/simulator-arm.cc \
		src/compiler/arm/code-generator-arm.cc \
		src/compiler/arm/instruction-selector-arm.cc \
		src/compiler/arm/linkage-arm.cc \
		src/ic/arm/access-compiler-arm.cc \
		src/ic/arm/handler-compiler-arm.cc \
		src/ic/arm/ic-arm.cc \
		src/ic/arm/ic-compiler-arm.cc \
		src/ic/arm/stub-cache-arm.cc

v8_local_src_files_arm64 := \
		src/arm64/assembler-arm64.cc \
		src/arm64/builtins-arm64.cc \
		src/arm64/code-stubs-arm64.cc \
		src/arm64/codegen-arm64.cc \
		src/arm64/cpu-arm64.cc \
		src/arm64/debug-arm64.cc \
		src/arm64/decoder-arm64.cc \
		src/arm64/delayed-masm-arm64.cc \
		src/arm64/deoptimizer-arm64.cc \
		src/arm64/disasm-arm64.cc \
		src/arm64/frames-arm64.cc \
		src/arm64/full-codegen-arm64.cc \
		src/arm64/instructions-arm64.cc \
		src/arm64/instrument-arm64.cc \
		src/arm64/interface-descriptors-arm64.cc \
		src/arm64/lithium-arm64.cc \
		src/arm64/lithium-codegen-arm64.cc \
		src/arm64/lithium-gap-resolver-arm64.cc \
		src/arm64/macro-assembler-arm64.cc \
		src/arm64/regexp-macro-assembler-arm64.cc \
		src/arm64/simulator-arm64.cc \
		src/arm64/utils-arm64.cc \
		src/compiler/arm64/code-generator-arm64.cc \
		src/compiler/arm64/instruction-selector-arm64.cc \
		src/compiler/arm64/linkage-arm64.cc \
		src/ic/arm64/access-compiler-arm64.cc \
		src/ic/arm64/handler-compiler-arm64.cc \
		src/ic/arm64/ic-arm64.cc \
		src/ic/arm64/ic-compiler-arm64.cc \
		src/ic/arm64/stub-cache-arm64.cc

v8_local_src_files_mips := \
		src/ic/mips/access-compiler-mips.cc\
		src/ic/mips/handler-compiler-mips.cc \
		src/ic/mips/ic-compiler-mips.cc \
		src/ic/mips/ic-mips.cc \
		src/ic/mips/stub-cache-mips.cc \
		src/mips/assembler-mips.cc \
		src/mips/builtins-mips.cc \
		src/mips/code-stubs-mips.cc \
		src/mips/codegen-mips.cc \
		src/mips/constants-mips.cc \
		src/mips/cpu-mips.cc \
		src/mips/debug-mips.cc \
		src/mips/deoptimizer-mips.cc \
		src/mips/disasm-mips.cc \
		src/mips/frames-mips.cc \
		src/mips/full-codegen-mips.cc \
		src/mips/interface-descriptors-mips.cc \
		src/mips/lithium-codegen-mips.cc \
		src/mips/lithium-gap-resolver-mips.cc \
		src/mips/lithium-mips.cc \
		src/mips/macro-assembler-mips.cc \
		src/mips/regexp-macro-assembler-mips.cc \
		src/mips/simulator-mips.cc

v8_local_src_files_mips64 := \
		src/ic/mips64/access-compiler-mips64.cc \
		src/ic/mips64/handler-compiler-mips64.cc \
		src/ic/mips64/ic-compiler-mips64.cc \
		src/ic/mips64/ic-mips64.cc \
		src/ic/mips64/stub-cache-mips64.cc \
		src/mips64/assembler-mips64.cc \
		src/mips64/builtins-mips64.cc \
		src/mips64/code-stubs-mips64.cc \
		src/mips64/codegen-mips64.cc \
		src/mips64/constants-mips64.cc \
		src/mips64/cpu-mips64.cc \
		src/mips64/debug-mips64.cc \
		src/mips64/deoptimizer-mips64.cc \
		src/mips64/disasm-mips64.cc \
		src/mips64/frames-mips64.cc \
		src/mips64/full-codegen-mips64.cc \
		src/mips64/interface-descriptors-mips64.cc \
		src/mips64/lithium-codegen-mips64.cc \
		src/mips64/lithium-gap-resolver-mips64.cc \
		src/mips64/lithium-mips64.cc \
		src/mips64/macro-assembler-mips64.cc \
		src/mips64/regexp-macro-assembler-mips64.cc \
		src/mips64/simulator-mips64.cc


v8_local_src_files_x86 := \
		src/compiler/ia32/code-generator-ia32.cc \
		src/compiler/ia32/instruction-selector-ia32.cc \
		src/compiler/ia32/linkage-ia32.cc \
		src/ia32/assembler-ia32.cc \
		src/ia32/builtins-ia32.cc \
		src/ia32/code-stubs-ia32.cc \
		src/ia32/codegen-ia32.cc \
		src/ia32/cpu-ia32.cc \
		src/ia32/debug-ia32.cc \
		src/ia32/deoptimizer-ia32.cc \
		src/ia32/disasm-ia32.cc \
		src/ia32/frames-ia32.cc \
		src/ia32/full-codegen-ia32.cc \
		src/ia32/interface-descriptors-ia32.cc \
		src/ia32/lithium-codegen-ia32.cc \
		src/ia32/lithium-gap-resolver-ia32.cc \
		src/ia32/lithium-ia32.cc \
		src/ia32/macro-assembler-ia32.cc \
		src/ia32/regexp-macro-assembler-ia32.cc \
		src/ia32/simulator-ia32.cc \
		src/ic/ia32/access-compiler-ia32.cc \
		src/ic/ia32/handler-compiler-ia32.cc \
		src/ic/ia32/ic-compiler-ia32.cc \
		src/ic/ia32/ic-ia32.cc \
		src/ic/ia32/stub-cache-ia32.cc

v8_local_src_files_x86_64 := \
		src/compiler/x64/code-generator-x64.cc \
		src/compiler/x64/instruction-selector-x64.cc \
		src/compiler/x64/linkage-x64.cc \
		src/ic/x64/access-compiler-x64.cc \
		src/ic/x64/handler-compiler-x64.cc \
		src/ic/x64/ic-compiler-x64.cc \
		src/ic/x64/ic-x64.cc \
		src/ic/x64/stub-cache-x64.cc \
		src/x64/assembler-x64.cc \
		src/x64/builtins-x64.cc \
		src/x64/code-stubs-x64.cc \
		src/x64/codegen-x64.cc \
		src/x64/cpu-x64.cc \
		src/x64/debug-x64.cc \
		src/x64/deoptimizer-x64.cc \
		src/x64/disasm-x64.cc \
		src/x64/frames-x64.cc \
		src/x64/full-codegen-x64.cc \
		src/x64/interface-descriptors-x64.cc \
		src/x64/lithium-codegen-x64.cc \
		src/x64/lithium-gap-resolver-x64.cc \
		src/x64/lithium-x64.cc \
		src/x64/macro-assembler-x64.cc \
		src/x64/regexp-macro-assembler-x64.cc \
		src/x64/simulator-x64.cc


# Enable DEBUG option.
ifeq ($(DEBUG_V8),true)
  LOCAL_SRC_FILES += \
		src/objects-debug.cc \
		src/prettyprinter.cc \
		src/regexp-macro-assembler-tracer.cc
endif

# The order of these JS library sources is important. The order here determines
# the ordering of the JS code in libraries.cc, which must be in a specific order
# to meet compiler dependency requirements.
V8_LOCAL_JS_LIBRARY_FILES := \
	src/runtime.js \
	src/v8natives.js \
	src/symbol.js \
	src/string.js \
	src/array.js \
	src/uri.js \
	third_party/fdlibm/fdlibm.js \
	src/math.js \
	src/apinatives.js \
	src/date.js \
	src/regexp.js \
	src/arraybuffer.js \
	src/typedarray.js \
	src/generator.js \
	src/object-observe.js \
	src/collection.js \
	src/weak-collection.js \
	src/collection-iterator.js \
	src/promise.js \
	src/messages.js \
	src/json.js \
	src/array-iterator.js \
	src/string-iterator.js \
	src/debug-debugger.js \
	src/mirror-debugger.js \
	src/liveedit-debugger.js \
	src/macros.py \
	src/i18n.js


V8_LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES := \
	src/macros.py \
	src/proxy.js \
	src/harmony-string.js \
	src/harmony-array.js \
	src/harmony-classes.js
