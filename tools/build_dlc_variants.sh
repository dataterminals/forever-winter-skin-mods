#!/usr/bin/env bash
# Build per-DLC-slot skin variants for a scav character (character-agnostic).
#
# Takes a skin mod's loose assets and produces one IoStore mod per DLC skin slot: the mesh is
# repathed + renamed onto that slot's asset (so the skin shows when that DLC skin is selected),
# the mod's materials/textures ride along, and the base character stays visually vanilla.
#
# !! $SRC must be extracted WITH THE FULL GAME MOUNTED (retoc -a <AES> to-legacy <Paks> …) so the
#    mesh Skeleton and material Parent imports resolve. Extracting the mod in isolation leaves them
#    as null placeholders -> in-game T-pose / broken materials. Verify each with:
#      fwrepath props <mesh> Skeleton   (-> GenericHumanoid_Skeleton*, not UnknownExport)
#      fwrepath props <material> Parent (-> a real material, not UnknownExport)
#    See README gotcha 1.
#
# Env:
#   SRC        loose legacy assets root (…/ForeverWinter/Content/… + scriptobjects.bin), context-extracted
#   OUT        output dir for the variant trios
#   RETOC, FWREPATH, FW_USMAP   tool paths
#   CHAR_DIR   e.g. Character/Scavengers/Female            (folder under Content, as the mod ships it)
#   BASE_MESH  e.g. SK_SCV_FL                              (the mesh asset name to repath; also the
#                                                           exclude prefix — meshes/physics named <BASE_MESH>* are dropped)
#   BASE_SELF  e.g. /Game/Character/Scavengers/Female/SK_SCV_FL   (the mesh's package self-path)
#   VARIANTS   newline-separated  slotFolder|objectName|modName  (objectName = the DT_SkinUIData object)
#   VOICE_DIR  optional: an Audio tree to bundle into every variant (character-wide voice)
set -euo pipefail
: "${SRC:?}"; : "${OUT:?}"; : "${RETOC:?}"; : "${FWREPATH:?}"; : "${FW_USMAP:?}"
: "${CHAR_DIR:?}"; : "${BASE_MESH:?}"; : "${BASE_SELF:?}"; : "${VARIANTS:?}"
export FW_USMAP MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*'

SRC_CHAR="$SRC/ForeverWinter/Content/$CHAR_DIR"
BASE_PKG_DIR="$(dirname "$BASE_SELF")"     # /Game/Character/Scavengers/Female
mkdir -p "$OUT"

while IFS='|' read -r FOLDER OBJ MODNAME; do
  [ -z "${FOLDER:-}" ] && continue
  echo "=== $MODNAME  (slot $FOLDER, object $OBJ) ==="
  STAGE="$OUT/.stage_$FOLDER"; rm -rf "$STAGE"
  DST="$STAGE/ForeverWinter/Content/$CHAR_DIR"; mkdir -p "$DST/Skins/$FOLDER"

  # materials + textures (drop the base meshes + physics asset — they collide with base; the
  # repathed mesh references the base physics instead). Portraits live outside CHAR_DIR, so
  # they're naturally excluded -> base character-select stays vanilla.
  for f in "$SRC_CHAR"/*; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in ${BASE_MESH}*) : ;; *) cp "$f" "$DST/";; esac
  done
  cp "$SRC/scriptobjects.bin" "$STAGE/scriptobjects.bin"

  # optional character-wide voice
  if [ -n "${VOICE_DIR:-}" ] && [ -d "$VOICE_DIR" ]; then
    mkdir -p "$STAGE/ForeverWinter/Content"; cp -r "$VOICE_DIR" "$STAGE/ForeverWinter/Content/"
  fi

  # repath + rename the mesh onto the DLC slot (export name must equal the DT object name;
  # FolderName drives the FPackageId so it must match the slot path too)
  "$FWREPATH" rename "$SRC_CHAR/$BASE_MESH.uasset" "$DST/Skins/$FOLDER/$OBJ.uasset" \
    "$BASE_MESH=$OBJ" \
    "$BASE_SELF=$BASE_PKG_DIR/Skins/$FOLDER/$OBJ"

  "$RETOC" to-zen "$STAGE" "$OUT/$MODNAME.utoc" --version UE5_4
  rm -rf "$STAGE"
  echo "    -> $OUT/$MODNAME.{utoc,ucas,pak}"
done <<< "$VARIANTS"
echo "=== done: $(ls "$OUT"/*.utoc 2>/dev/null | wc -l) variants ==="
