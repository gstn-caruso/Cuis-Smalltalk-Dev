# qSmalltalk

**A Smalltalk that diverges from Cuis on purpose.**

qSmalltalk is a hard fork of [Cuis Smalltalk](https://cuis-smalltalk.org/) 7.7. It is
**not Cuis**, and it is **not compatible with Cuis** — not with its packages, not with
its tutorials, and increasingly not with its semantics. We keep the parts of Cuis we love
(the small kernel, the Smalltalk-80 spirit, Morphic) and we feel free to break everything
else when breaking it makes the system simpler and easier to learn.

> ⚠️ **This is an experiment, and a moving target.** No backwards compatibility is
> promised — with Cuis or with our own past versions. If you need a stable, compatible
> Smalltalk, use [Cuis](https://github.com/Cuis-Smalltalk/Cuis-Smalltalk-Dev) instead.

## The rationale: less to keep in your head

Every system asks something of the person using it: how many concepts, names, and special
cases you must hold in your head to get anything done. That cost — the **cognitive
complexity** of the system — is what qSmalltalk exists to lower.

Cuis already fights complexity harder than any other Smalltalk. qSmalltalk pushes further
by spending the one thing Cuis won't: **backwards compatibility**. We accept the cost
deliberately.

**Every breaking change must buy a real reduction in what you need to understand.**
Compatibility is not free either — it is paid in confusing names, redundant protocols, and
special cases kept alive only because something, somewhere, once depended on them. We would
rather pay once, by breaking, than forever, in confusion.

This shapes every decision:

- **Less is more.** Fewer classes, fewer messages, fewer ways to do the same thing.
- **Clarity over history.** A name or protocol that exists only for historical reasons gets
  renamed or deleted.
- **Teachable first.** The test for every change: *does this help someone who just opened
  the image for the first time?* If not, it goes.

## Where this leads

The divergence is not cosmetic; it reaches into the core semantics of the language.
Some examples of where lowering cognitive complexity takes us:

- **Collections** — one clear way to iterate, query, and transform, with the legacy and
  duplicated selectors removed, instead of several overlapping ones.
- **Tonel as the source of truth** — the image rebuilt from versioned, readable sources
  instead of carrying accumulated change sets.
- **A single, obvious way** to run, build, and ship the image.

> 📌 *Status: direction, not done.* These are the north star, not shipped features. Each
> will land as a deliberate, breaking change.

## Running qSmalltalk

You need two things: the **VM** (the virtual machine that runs Smalltalk) and the
**image** (the snapshot of the running system, included in this repo under `CuisImage/`).

### From a release (recommended)

Download the bundle for your platform from the
[Releases page](https://github.com/gstn-caruso/Cuis-Smalltalk-Dev/releases), unzip it, and
run the launcher inside (`RunQSmalltalkOnMac.sh`, `RunQSmalltalkOnLinux.sh`, …). Each
release lists the exact image and VM versions it ships, and **bundles the VM** — nothing
else to install.

### From the repo (for development)

The VM is **not** vendored in this repo. The release pipeline downloads it from the
[OpenSmalltalk VM releases](https://github.com/OpenSmalltalk/opensmalltalk-vm/releases); for
local development, point any recent OpenSmalltalk VM at the image:

```bash
/path/to/Squeak CuisImage/Cuis7.7-*.image
```

## Status & expectations

- **Experimental.** APIs change without notice. Not for production.
- **Not Cuis-compatible.** Don't expect Cuis packages or guides to work here.
- **Help wanted on the direction**, not on preserving the past.

## Credits

qSmalltalk stands on the shoulders of [Cuis Smalltalk](https://cuis-smalltalk.org/) by
Juan Vuletich and contributors, which itself descends from Squeak and the original
Smalltalk-80 at Xerox PARC. We are grateful for all of it — and we diverge with respect.

Special thanks to:

- **Facundo Gelatti** — for the MCP connector.
- **Máximo Prieto** — for building a new paradigm that made the birth of this fork possible.

## License

MIT. See [LICENSE](LICENSE).
