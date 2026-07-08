#!/usr/bin/env bash
# Build Shaman DLC-slot skin variants from an unpacked base-Shaman skin mod.
#
# Takes a skin mod that replaces the DEFAULT Shaman mesh (/Game/.../Shaman/SK_SCV_SHM)
# and produces one IoStore mod per Shaman DLC skin slot. Each variant repaths + renames
# the mesh onto that slot's mesh asset so the skin shows when that DLC skin is selected,
# leaving the base Shaman (and its portrait/physics/voice) 100% vanilla.
#
# Requires: retoc (RETOC), fwrepath.exe (FWREPATH), a .usmap (FW_USMAP), and the loose
# legacy assets produced by `retoc to-legacy <mod>+<global> <SRC>`.
#
# Env inputs:
#   SRC       dir with unpacked legacy assets (…/ForeverWinter/Content/… + scriptobjects.bin)
#   OUT       output dir for the variant .utoc/.ucas/.pak trios
#   RETOC     path to retoc.exe
#   FWREPATH  path to fwrepath.exe
#   FW_USMAP  path to the game .usmap
set -euo pipefail

: "${SRC:?}"; : "${OUT:?}"; : "${RETOC:?}"; : "${FWREPATH:?}"; : "${FW_USMAP:?}"
export FW_USMAP MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*'

SHM="Character/Scavengers/SHAMAN"                     # folder as shipped by the mod
SRC_SHM="$SRC/ForeverWinter/Content/$SHM"
BASE_SELF="/Game/Character/Scavengers/Shaman/SK_SCV_SHM"   # the mesh's self-path in the mod

mkdir -p "$OUT"

# slot folder | in-package object name (from DT_SkinUIData) | output mod name
VARIANTS=(
  "DSQ|SK_SCV_SHM_DSQ|SHM_UMP45_DuneWraith_P"
  "DWK|SK_SCV_SHM_DWK|SHM_UMP45_Dedwak_P"
  "Dogmask|SK_SCV_SHM_Doghead|SHM_UMP45_EtherealPup_P"
  "MAY|SK_SCV_SHM_MAY|SHM_UMP45_ShamanMay_P"
)

for v in "${VARIANTS[@]}"; do
  IFS='|' read -r FOLDER OBJ MODNAME <<< "$v"
  echo "=== building $MODNAME  (slot $FOLDER, object $OBJ) ==="
  STAGE="$OUT/.stage_$FOLDER"; rm -rf "$STAGE"
  DST="$STAGE/ForeverWinter/Content/$SHM"; mkdir -p "$DST/Skins/$FOLDER"

  # materials + textures (everything the mod ships EXCEPT the mesh + physics asset,
  # which collide with base Shaman; the repathed mesh references base physics instead)
  for f in "$SRC_SHM"/*; do
    b=$(basename "$f")
    case "$b" in SK_SCV_SHM.*|SK_SCV_SHM_PhysicsAsset.*) : ;; *) cp "$f" "$DST/";; esac
  done
  cp "$SRC/scriptobjects.bin" "$STAGE/scriptobjects.bin"

  # voice lines (unchanged base-VO overrides) — bundled so each variant is a self-contained
  # zip. Character-wide, so UMP45 voice plays on any Shaman skin once this variant is installed.
  if [ "${INCLUDE_VOICE:-1}" = "1" ] && [ -d "$SRC/ForeverWinter/Content/Audio" ]; then
    cp -r "$SRC/ForeverWinter/Content/Audio" "$STAGE/ForeverWinter/Content/"
  fi

  # repath + rename the mesh onto the DLC slot (export name must match the DT object name)
  "$FWREPATH" rename "$SRC_SHM/SK_SCV_SHM.uasset" "$DST/Skins/$FOLDER/$OBJ.uasset" \
    "SK_SCV_SHM=$OBJ" \
    "$BASE_SELF=/Game/Character/Scavengers/Shaman/Skins/$FOLDER/$OBJ"

  "$RETOC" to-zen "$STAGE" "$OUT/$MODNAME.utoc" --version UE5_4
  rm -rf "$STAGE"
  echo "    -> $OUT/$MODNAME.{utoc,ucas,pak}"
done
echo "=== done: $(ls "$OUT"/*.utoc | wc -l) variants ==="
