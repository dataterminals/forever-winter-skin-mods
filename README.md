# Forever Winter — skin-mod DLC-slot retargeting

Tooling to take a **scav skin mod that replaces a character's default skin** and re-aim it at
one of that character's **DLC skin slots** instead — so two players on the same scav can look
different, and a modded look no longer disappears when a DLC skin is equipped.

First target: the **UMP45** (Girls' Frontline) mod for **Shaman**, retargeted onto each of
Shaman's 4 DLC slots. See [`docs/shaman-skin-map.md`](docs/shaman-skin-map.md).

> **Note on assets.** The cooked `.uasset/.pak/.ucas/.utoc` and the source mod are **not**
> committed (see `.gitignore`) — they contain third-party (Girls' Frontline) and game-derived
> content. Only our tooling and docs live here. Redistribute built mods only with the original
> mod author's permission.

## How it works

Forever Winter picks a skin via the `DT_SkinUIData` datatable: each row maps a selectable skin to
a **skeletal-mesh asset path**. Default skins point at the character root
(`…/Scavengers/Shaman/SK_SCV_SHM`); DLC skins point at `…/Scavengers/Shaman/Skins/<CODE>/SK_…`.
A normal skin mod overrides the *default* mesh path, so a DLC skin (a different path) bypasses it.

To retarget a mod onto a DLC slot you make its mesh **become** that slot's mesh asset:

1. `retoc to-legacy` the IoStore mod (with the game's `global.utoc` so ScriptObjects resolve)
   → loose cooked `.uasset/.uexp`.
2. For each DLC slot, **repath + rename** the mesh so its package identity matches that slot:
   - move the file to `…/Shaman/Skins/<CODE>/<OBJ>.uasset`
   - rename the export FName `SK_SCV_SHM` → `<OBJ>` (must equal the DT object name, e.g.
     `SK_SCV_SHM_DSQ`, `SK_SCV_SHM_Doghead`)
   - **set the header `FolderName` to the new `/Game/…/Skins/<CODE>/<OBJ>` path** — see gotcha.
   - keep the mod's own materials/textures (they don't collide with base); reference the base
     physics asset; ship no base mesh or portrait, so the default Shaman stays visually vanilla.
   - bundle the mod's voice-line overrides unchanged (`INCLUDE_VOICE=1`, default) so each variant
     is a self-contained zip. Voice is character-wide — it plays on any Shaman skin once installed.
3. `retoc to-zen` → a fresh `.utoc/.ucas/.pak` mod for that slot.

### ⚠ The FolderName / FPackageId gotcha

The game finds a package by its **FPackageId** (an IoStore chunk id), which `retoc to-zen` computes
from the **`FolderName` field in the package-summary header** — *not* the file path and *not* the
name map. Editing only the name map leaves the header saying the base path, so **every variant
collides on one chunk id** (install more than one and only the last works; likely none resolve on
their slot). `fwrepath` fixes both the name map *and* `FolderName`. Verify by diffing `retoc list`
chunk ids across variants — only the type-06 `ContainerHeader` should differ.

## Build

```bash
# tools you need (not vendored): retoc (github.com/trumank/retoc), the .NET SDK, a game .usmap
export SRC=…/unpacked            # `retoc to-legacy` output (+ scriptobjects.bin)
export OUT=…/dist
export RETOC=…/retoc.exe
export FWREPATH=…/fwrepath/bin/Release/net10.0/fwrepath.exe
export FW_USMAP=…/ForeverWinter-5.4.2.usmap
bash tools/build_shaman_dlc_variants.sh
```

## Layout

```
tools/fwrepath/                 UAssetAPI console tool: inspect / rename exports + FolderName
tools/build_shaman_dlc_variants.sh   build all 4 Shaman DLC-slot variants
docs/shaman-skin-map.md         DT_SkinUIData: Shaman default + DLC slots -> mesh paths
```

## Install (for the built mods)

Drop a variant's `.pak/.ucas/.utoc` trio into `…/The Forever Winter/Windows/ForeverWinter/Content/Paks/~mods/`
(create `~mods` if absent). Select Shaman, then the matching DLC skin, in the character menu.
You must own the DLC slot you target. In co-op, skins render per-client.
