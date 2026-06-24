# Elevate Prototyping Kit

A zero-build-tools HTML prototyping toolkit for G2 design explorations. Provides everything needed to build Elevate-fidelity explorations in plain HTML — no bundler, no framework.

## What's in this kit

- **CSS tokens** (`tokens/elevate.css`) — Design tokens as CSS custom properties, with backward-compatible aliases to `@g2crowd/elevate`'s `--elv-*` variables
- **Component CSS** (`components/elevate.css`) — Full Elevate component + utility class library. Sourced from UE production Elevate CSS.
- **Component examples** (`examples/`) — 45 elevate-g2 component pages, synced from [`g2crowd/elevate-g2`](https://github.com/g2crowd/elevate-g2). Browse by opening `examples/index.html`.
- **Icons** (`icons/icons.css`) — 305 G2 UI icons as CSS background-image classes
- **Component templates** (`components/templates/`) — Copy-paste HTML for 44 components (self-contained `<style>` blocks)
- **Nav shells** (`components/templates/navigation/`) — Complete G2 navigation patterns (topbar, vendor admin, buyer profile, teams portal)
- **Design system spec** (`design-system/DESIGN.md`) — Authoritative Elevate spec for agent and human reference
- **Logo assets** (`assets/logos/`) — G2 SVG logos

Examples are reference gallery pages showing real elevate-g2 CSS in use. Templates are copy-paste starters for explorations.

## Relationship to @g2crowd/elevate

This kit wraps [`@g2crowd/elevate`](https://github.com/g2crowd/elevate-g2) for zero-build-tools HTML prototyping:

- `tokens/elevate.css` provides backward-compatible aliases (e.g. `--bg-primary` → `var(--elv-bg-primary)`) and hardcoded values for tokens not yet exposed as CSS vars by the npm package
- `components/elevate.css` is synced from the npm dist via `sync.sh`
- `sync.sh` also syncs the `examples/` directory from the source repo

## Quick start

Include three CSS files in your HTML (adjust path depth to match your file's location):

```html
<!-- From epics/{epic}/explorations/*.html: depth = ../../../ -->
<link rel="stylesheet" href="../../../shared/elevate-prototyping-kit/tokens/elevate.css">
<link rel="stylesheet" href="../../../shared/elevate-prototyping-kit/components/elevate.css">
<link rel="stylesheet" href="../../../shared/elevate-prototyping-kit/icons/icons.css">
```

Wrap all content in a container with the `elv` attribute:

```html
<div elv class="elv-max-w-screen-xl elv-mx-auto elv-p-8">
  <!-- Your exploration here -->
  <button class="btn btn--primary btn--md">Primary Action</button>
</div>
```

## CSS path depth reference

| File location | CSS prefix |
|---|---|
| Root `index.html` | `./shared/elevate-prototyping-kit/` |
| `epics/{epic}/index.html` | `../../shared/elevate-prototyping-kit/` |
| `epics/{epic}/explorations/*.html` | `../../../shared/elevate-prototyping-kit/` |

## Syncing from upstream

When `@g2crowd/elevate` releases a new version with improved utility coverage:

```bash
./sync.sh 1.3.0  # syncs both CSS and examples
git add components/elevate.css
git commit -m "Sync components/elevate.css from @g2crowd/elevate@1.4.0"
git push
```

## Adding new utilities

When an exploration needs a Tailwind utility class that's not in the npm dist (e.g., `elv-grid-cols-4`, `elv-gap-8`), add it to `utilities.css`:

1. Find the class definition in `shared/elevate-lite/components/elevate.css` (the frozen UE production CSS)
2. Copy the rule block to `utilities.css`
3. Include any responsive variants (`@media` breakpoint versions) if needed
4. Commit the change to this repo

`utilities.css` is maintained manually — `sync.sh` does not overwrite it.

## Design system reference

- **Authoritative spec**: [`design-system/DESIGN.md`](./design-system/DESIGN.md)
- **Visual reference**: [Elevate Lookbook](https://www.g2.test/elevate/lookbook)
- **Component templates**: [`components/templates/`](./components/templates/)

## License

Internal G2 use only.
