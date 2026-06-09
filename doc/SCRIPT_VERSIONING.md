# Script Versioning Convention (Shell)

## Scope

This convention applies to helper libraries under `dev-utils/bin/lib`.

## Naming Convention

Use major-only versioning in file names:

- `lib_<domain>_v1.sh`
- `lib_<domain>_v2.sh`

Examples:

- `lib_env_utils_v1.sh`
- `lib_env_utils_v2.sh`
- `lib_string_utils_v1.sh`

## Stable Entry Point

Keep one stable entry file per library:

- `lib_<domain>.sh`

This file is the only path consumers should `source` in new scripts.

Example:

- `source "$PROJECT_PATH/bin/lib/lib_env_utils.sh"`

## Compatibility Rules

1. Breaking change: create next major (`v1` -> `v2`).
2. Backward-compatible change: update the same major file.
3. Patch/minor differences are tracked in git history and header comments, not in file name.
4. At most two active majors at once: current + one legacy.

## Lifecycle Policy

- Current major: receives all fixes and improvements.
- Legacy major: only critical fixes for a limited period.
- Removal rule: remove legacy major after all consumers are migrated and one release cycle is completed.

## Migration Policy

1. New scripts must source the stable file (`lib_<domain>.sh`).
2. Existing scripts can keep old references during migration.
3. When all consumers are migrated, remove direct references to old majors.
4. Keep migration atomic per script: source path update + smoke test.

## Header Template (Versioned Library)

Use this template in `lib_<domain>_vN.sh` files:

```bash
#!/usr/bin/env bash

#### Description: <short purpose>
#### Library: lib_<domain>
#### Version: vN
#### Compatibility: <what this major supports>
#### Maintainer: <name or team>
#### Last update: YYYY-MM-DD

# Changelog:
# - YYYY-MM-DD: Initial vN.
# - YYYY-MM-DD: <change summary>

#### THIS FILE IS SOURCED BY OTHER SCRIPTS.
#### KEEP BACKWARD COMPATIBILITY WITHIN THE SAME MAJOR.
```

## Header Template (Stable Entry File)

Use this template in `lib_<domain>.sh`:

```bash
#!/usr/bin/env bash

#### Description: Stable entry point for lib_<domain>
#### Notes: This file should source the active major version.

# Active major selector (single source of truth)
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)/lib_<domain>_vN.sh"
```

## Quick Checklist Before Releasing a New Major

- New major file created (`vN+1`).
- Stable entry file points to the intended active major.
- At least one consumer script tested with the stable entry file.
- Migration note added to project changelog.
