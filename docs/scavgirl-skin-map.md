# Scav Girl (Female) skins — `DT_SkinUIData` map

From `/Game/FW/Player/Data/DT_SkinUIData` (build 24045295). Scav Girl meshes ride
`/Game/Animations/GenericHumanoid/GenericHumanoid_Skeleton` (the plain skeleton — **not** the
`_MainCharacters` variant Shaman uses).

Base path prefix: `/Game/Character/Scavengers/Female/`

| Row | In-game name | Type | Mesh package (relative) | Object name |
|-----|--------------|------|-------------------------|-------------|
| `ScavGirl0` | Default Skin 1 | base | `SK_SCV_FL` | `SK_SCV_FL` |
| `ScavGirl1` | Default Skin 2 | base | `SK_SCV_FL1` | `SK_SCV_FL1` |
| `ScavGirl2` | Default Skin 3 | base | `SK_SCV_FL2` | `SK_SCV_FL2` |
| `ScavGirl3` | Default Skin 4 | base | `SK_SCV_FL3` | `SK_SCV_FL3` |
| `ScavGirl4` | Default Skin 5 | base | `SK_SCV_FL4` | `SK_SCV_FL4` |
| `ScavGirlSPT` | **Blind Runner** | DLC | `Skins/SPT/SK_SCV_FL_SPT` | `SK_SCV_FL_SPT` |
| `ScavGirlDec2025` | **Kevlar Cake** | DLC | `Skins/DEC/SK_FL_SCV_DEC` | `SK_FL_SCV_DEC` |
| `Skin.Girl.DSQ` | **Emberdrift** | DLC | `Skins/DSQ/SK_SCV_FL_DSQ` | `SK_SCV_FL_DSQ` |
| `Skin.Girl.MAY` | **Scav Female May** | DLC | `Skins/MAY/SK_SCV_FL_May` | `SK_SCV_FL_May` |

Notes:
- Watch the **object names**: Kevlar Cake is `SK_FL_SCV_DEC` (FL/SCV swapped vs the others), and
  the May slot is `SK_SCV_FL_May` (lower-case `ay`). The mesh export must be renamed to match
  exactly or the skin won't resolve.
- An `SK_SCV_FL_OCT` mesh exists in the files but isn't wired into `DT_SkinUIData`, so it's not a
  selectable slot — skip it.
- Lenna/UMP9 material instances (`M_UMP9_*`) parent to the base game master `M_FW_Char`; the mesh
  and materials must be extracted with game context so that parent (and the skeleton) resolve.
