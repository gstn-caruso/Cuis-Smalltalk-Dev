# Image Smells Report

Scope: findings were produced from a live Cuis image via MCP (method/source inspection) plus repo-wide greps for TODO/FIXME/HACK/XXX/DEPRECATED markers.

## High Impact / High Risk

### Massive Duplication In Performance-Critical Rendering
- Where: `VectorEngineSubPixel>>blendStrokeAndFill`, `VectorEngineWholePixel>>blendStrokeAndFill`, `VectorEngineSubPixel>>blendFillOnly`, `VectorEngineWholePixel>>blendFillOnly`.
- Also related repo sources: `Packages/Features/VectorEnginePlugin.pck.st` (multiple `blend*` variants).
- Smell: very large methods, duplicated structure, hot-path code.
- Risk: subtle rendering artifacts, hard-to-review changes, correctness fixes become risky.
- Smallest tidy-first step: extract the shared loop skeleton (scanline/segment traversal) and keep only pixel-blending differences in small strategy methods.

### God Method For Snapshot/Quit Lifecycle
- Where: `SystemDictionary>>snapshot:andQuit:embedded:clearAllClassState:`.
- Smell: too many responsibilities, heavy global state coordination, order-dependent operations.
- Risk: image integrity regressions, shutdown/startup flakiness.
- Smallest tidy-first step: extract cohesive private methods while preserving exact sequencing.

### God Method For Display Resize And UI Lifecycle
- Where: `WorldMorph>>checkForNewScreenSize`.
- Smell: debounce, ScaleFactor changes, display allocation, canvas lifecycle, and process control are mixed.
- Risk: UI restart loops, resize glitches, memory fragmentation.
- Smallest tidy-first step: split into intention-revealing private methods and replace magic property keys with named constants.

### Large Primitive Simulation Dispatcher With Many Special Cases
- Where: `ContextPart>>doPrimitive:method:receiver:args:`.
- Smell: large branching dispatcher with embedded special cases (perform, FFI, Mutex, executeMethod, etc.).
- Risk: debugger/simulator behavior regressions.
- Smallest tidy-first step: extract per-intent primitive handlers into well-named private methods and keep a top-level dispatcher.

## Medium Impact

### Long Method Mixing Input Decoding And Platform Quirks
- Where: `HandMorph>>generateKeyboardEvent:`.
- Smell: modifier decoding, platform quirks, ctrl/cmd normalization, and scroll inference in one method.
- Risk: keyboard shortcuts, international keyboards, scroll gesture inference.
- Smallest tidy-first step: extract pure helper methods (no behavior change) and leave a linear pipeline in the original.

### Duplicated Menu Specs Across Tools
- Where: `BrowserWindow>>classListMenuSpec`, `BrowserWindow>>messageListMenuSpec`, `MethodSetWindow>>messageListMenuSpec`, `TextEditor>>defaultMenuSpec`, `SmalltalkEditor>>defaultMenuSpec`, `ChangeListWindow>>listMenuSpec`.
- Smell: large literal spec arrays duplicated across tools.
- Risk: drift over time, inconsistent shortcuts/menus.
- Smallest tidy-first step: share spec fragments (class-side methods) and refactor one tool at a time with identical resulting specs.

### Complex Layout Allocation Logic Split By Axis
- Where: `ColumnLayout>>heightsFor:within:minLayoutExtentCache:` and `RowLayout>>widthsFor:within:minLayoutExtentCache:`.
- Smell: complex proportional-allocation logic duplicated conceptually for row/column.
- Risk: layout glitches and brittle fixes.
- Smallest tidy-first step: extract a shared allocator parameterized by axis selectors; add layout-focused SUnit tests for representative morph sets.

### God Classes (Very Large Surface Area)
- Examples: `Morph` and `SystemDictionary`.
- Smell: mixed responsibilities; browsing and refactoring are slower and riskier.
- Smallest step: identify a couple of cohesive clusters (by protocol) and isolate behind helper classes or clearer protocol partitions.

## Low To Medium Impact (Naming / Data / Maintainability)

### Typo Selector Becoming Permanent API
- Where: `SmalltalkEditor>>keyboardShortuctsSubmenuSpec` (misspelling).
- Smell: naming inconsistency reduces discoverability and spreads.
- Smallest tidy-first step: add correctly spelled delegating alias and migrate internal senders.

### Large Literal Data Embedded In Executable Method
- Where: `SystemDictionary>>knownInitialsAndNames`.
- Smell: data list embedded in method body; hard to validate.
- Smallest step: move to a class-side constant method and add an optional consistency checker (duplicates/near-duplicates).

### Documentation Block Embedded In Operational Method
- Where: `SystemDictionary>>vmParameterAt:`.
- Smell: huge doc/spec block in a method that is otherwise a wrapper.
- Smallest step: move registry documentation to a class comment or a dedicated class-side method.

## Marked Debt (TODO/FIXME/HACK/DEPRECATED)

### CoreUpdates
- `CoreUpdates/7841-*`: protocol labeled `'TEMPORARY HACK'`.
- `CoreUpdates/7476-*` and `CoreUpdates/7483-*`: `FIXME` around an event-dispatch/focus edge case.

### Packages
- `Packages/Features/WebClient.pck.st`: `FIXME` (HTTP time format), `TODO` (authenticated user id).
- `Packages/Features/Printf.pck.st`: multiple `TODO` notes around defaults and float formatting assumptions.
- `Packages/Features/Graphics-Files-Additional.pck.st`: multiple `TODO` notes to validate PNG fields.
- `Packages/System/OpenCL.pck.st`: multiple deprecated notes plus a `TODO` about event completion checks.
- `Packages/System/Network-Kernel.pck.st`: explicit `deprecated:` calls.

## Architectural Coupling / Global State Risks

- Globals and singletons are central to lifecycle flows: `Preferences`, `Sensor`, `UISupervisor`, process management.
- Resize and snapshot flows mutate shared global state and coordinate multiple subsystems; sequencing is a hidden dependency.

## Tooling Capability Gap

- `SystemNavigation` was absent from the inspected running image. Many refactoring workflows assume it exists.
