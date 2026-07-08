# Shaman skins — `DT_SkinUIData` map

From `/Game/FW/Player/Data/DT_SkinUIData` (build 24045295). Each selectable skin row points at a
skeletal-mesh asset (`Skin.AssetPathName = <package>.<object>`). All Shaman meshes ride
`/Game/Animations/GenericHumanoid/GenericHumanoid_Skeleton_MainCharacters`.

Base path prefix: `/Game/Character/Scavengers/Shaman/`

| Row | In-game name | Type | Mesh package (relative) | Object name |
|-----|--------------|------|-------------------------|-------------|
| `Shaman0` | Default Skin 1 | base | `SK_SCV_SHM` | `SK_SCV_SHM` |
| `ShamanDogHead` | **Ethereal Pup** | DLC | `Skins/Dogmask/SK_SCV_SHM_Doghead` | `SK_SCV_SHM_Doghead` |
| `ShamanDec2025` | **Dedwak** | DLC | `Skins/DWK/SK_SCV_SHM_DWK` | `SK_SCV_SHM_DWK` |
| `Skin.Shaman.DSQ` | **Dune Wraith** | DLC | `Skins/DSQ/SK_SCV_SHM_DSQ` | `SK_SCV_SHM_DSQ` |
| `Skin.Shaman.May` | **Shaman May** | DLC | `Skins/MAY/SK_SCV_SHM_MAY` | `SK_SCV_SHM_MAY` |

Notes:
- The **object name** (part after the `.`) is what a DLC variant's mesh export must be renamed to —
  the game resolves `<package>.<object>` strictly, so a mismatch = skin fails to load.
- Ethereal Pup's object is `SK_SCV_SHM_Doghead` (folder `Dogmask`) — the one case where folder
  name and object suffix differ.
- Shaman has only **one** default skin, so the DLC slots are the only way to vary its look —
  which makes them ideal "mod slots".
- DWK and DSQ ship their own `…_PhysicsAsset` in vanilla; Dogmask/MAY reuse the base one. Variants
  here reference the **base** physics asset either way (same skeleton), so they don't touch it.
