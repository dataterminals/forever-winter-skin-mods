# UMP45 → Shaman DLC-slot mods — install

Each mod is **self-contained**: it puts the UMP45 look on **one** of Shaman's DLC skin slots
*and* replaces Shaman's voice with UMP45's. The **default** Shaman skin stays visually vanilla,
so you and a buddy can both play Shaman and look different.

Distributed as four standalone zips — install whichever slot(s) you want.

## Install

Extract a mod's `.pak` + `.ucas` + `.utoc` **trio** into:

```
…\The Forever Winter\Windows\ForeverWinter\Content\Paks\~mods\
```

Create the `~mods` folder if it doesn't exist. To uninstall, delete the files.
You can install **all four at once** — they target different slots and don't conflict.

## What each mod does

| Zip / trio | Pick Shaman + this skin → UMP45 model | Voice |
|------------|----------------------------------------|-------|
| `SHM_UMP45_EtherealPup_P` | **Ethereal Pup** (Dogmask) | UMP45 |
| `SHM_UMP45_Dedwak_P`      | **Dedwak** (DWK)           | UMP45 |
| `SHM_UMP45_DuneWraith_P`  | **Dune Wraith** (DSQ)      | UMP45 |
| `SHM_UMP45_ShamanMay_P`   | **Shaman May** (MAY)       | UMP45 |

## Notes

- You must **own** the DLC skin slot you pick — the mod swaps the model, it doesn't unlock the slot.
- The default Shaman skin and its portrait are visually untouched.
- **Voice is character-wide** (the engine can't tie it to one skin): once any of these is installed,
  Shaman sounds like UMP45 on *every* skin, including the default. Installing several is fine — the
  voice files are identical across them.
- In co-op, each player's game renders skins from their own install. Pick different slots and you
  won't be doppelgangers even if only one of you has the mod.
