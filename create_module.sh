#!/usr/bin/env bash
set -euo pipefail

# create_module.sh (v2)
# Crea un módulo Tuist con Project.swift + Sources + Tests en el directorio indicado.
# Por defecto NO modifica Workspace.swift. Usa --workspace auto para crearlo si no existe.
#
# Uso:
#   bash create_module.sh <ModuleName> [--type framework|staticFramework|staticLibrary] \
#     [--deps Mod1,Mod2,...] [--ios 17.0] [--dir Modules|Dependencies] [--bundle-base com.dejares] [--workspace auto|skip]
#
# Ejemplos:
#   bash create_module.sh CoreDomain --dir Modules
#   bash create_module.sh InfraPersistenceSwiftData --dir=Dependencies --deps InfraPersistenceAbstractions
#   bash create_module.sh CorePersistenceAdapter --dir Modules --deps CoreDomain,InfraPersistenceAbstractions

APP_NAME_DEFAULT="DejarEs"
BUNDLE_BASE_DEFAULT="com.dejares"
IOS_VERSION_DEFAULT="17.0"
PRODUCT_DEFAULT="framework"     # framework|staticFramework|staticLibrary
BASE_DIR_DEFAULT="Modules"
WORKSPACE_MODE_DEFAULT="skip"   # skip|auto

require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Falta '$1'"; exit 1; }; }
title() { echo; echo "=== $* ==="; }

if [[ $# -lt 1 ]]; then
  echo "Uso: bash $0 <ModuleName> [--type framework|staticFramework|staticLibrary] [--deps Mod1,Mod2,...] [--ios 17.0] [--dir Modules|Dependencies] [--bundle-base com.dejares] [--workspace auto|skip]"
  exit 1
fi

MODULE_NAME="$1"; shift

PRODUCT="$PRODUCT_DEFAULT"
DEPS_CSV=""
IOS_VERSION="$IOS_VERSION_DEFAULT"
APP_NAME="$APP_NAME_DEFAULT"
BUNDLE_BASE="$BUNDLE_BASE_DEFAULT"
BASE_DIR="$BASE_DIR_DEFAULT"
WORKSPACE_MODE="$WORKSPACE_MODE_DEFAULT"

# Parse de flags con soporte --key value y --key=value
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type|--deps|--ios|--bundle-base|--app-name|--dir|--workspace)
      key="$1"; val="${2:-}"; shift 2;;
    --type=*|--deps=*|--ios=*|--bundle-base=*|--app-name=*|--dir=*|--workspace=*)
      key="${1%%=*}"; val="${1#*=}"; shift 1;;
    *)
      echo "⚠️ Opción desconocida: $1"; shift; continue;;
  esac
  case "$key" in
    --type) PRODUCT="$val";;
    --deps) DEPS_CSV="$val";;
    --ios) IOS_VERSION="$val";;
    --bundle-base) BUNDLE_BASE="$val";;
    --app-name) APP_NAME="$val";;
    --dir) BASE_DIR="$val";;
    --workspace) WORKSPACE_MODE="$val";;
  esac
done

case "$PRODUCT" in framework|staticFramework|staticLibrary) ;; *) echo "❌ --type inválido"; exit 1;; esac
case "$WORKSPACE_MODE" in skip|auto) ;; *) echo "❌ --workspace debe ser auto|skip"; exit 1;; esac
case "$BASE_DIR" in Modules|Dependencies) ;; *) echo "❌ --dir debe ser Modules o Dependencies"; exit 1;; esac

require_cmd tuist
mkdir -p "$BASE_DIR" Apps

NAME_LC="$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')"

create_skeleton() {
  local name="$1"
  mkdir -p "$BASE_DIR/$name/Sources" "$BASE_DIR/$name/Tests"
  cat > "$BASE_DIR/$name/Sources/${name}.swift" <<EOF
public enum ${name} { }
EOF
  cat > "$BASE_DIR/$name/Tests/${name}Tests.swift" <<'EOF'
import XCTest
final class DummyTests: XCTestCase {
  func test_dummy() { XCTAssertTrue(true) }
}
EOF
}

# Deduce carpeta base de un dep por nombre si no viene con prefijo
base_for_dep() {
  local dep="$1"
  if [[ "$dep" == Modules/* ]]; then echo "Modules"; return; fi
  if [[ "$dep" == Dependencies/* ]]; then echo "Dependencies"; return; fi
  if [[ "$dep" == Infra* ]]; then echo "Dependencies"; return; fi
  # Por convención: Core*/Feature* en Modules
  echo "Modules"
}

# Nombre puro del dep (sin prefijo de carpeta)
dep_basename() {
  local dep="$1"
  echo "${dep##*/}"
}

# Calcula path relativo desde $BASE_DIR/$MODULE_NAME a <depBase>/<depName>
rel_path_to_dep() {
  local depBase="$1" depName="$2"
  if [[ "$BASE_DIR" == "$depBase" ]]; then
    echo "../$depName"
  elif [[ "$BASE_DIR" == "Modules" && "$depBase" == "Dependencies" ]]; then
    echo "../../Dependencies/$depName"
  elif [[ "$BASE_DIR" == "Dependencies" && "$depBase" == "Modules" ]]; then
    echo "../../Modules/$depName"
  else
    # fallback
    echo "../$depName"
  fi
}

gen_dep_lines() {
  local csv="$1"
  [[ -z "$csv" ]] && return 0
  IFS=',' read -ra arr <<< "$csv"
  for raw in "${arr[@]}"; do
    dep="$(echo "$raw" | xargs)"
    [[ -z "$dep" ]] && continue
    local depBase depName rel
    depBase="$(base_for_dep "$dep")"
    depName="$(dep_basename "$dep")"
    rel="$(rel_path_to_dep "$depBase" "$depName")"
    echo "        .project(target: \"$depName\", path: \"$rel\"),"
  done
}

write_project_swift() {
  local name="$1" product="$2" ios="$3" bundle="$4" name_lc="$5" deps_csv="$6"
  local deps_formatted; deps_formatted="$(gen_dep_lines "$deps_csv")"

  cat > "$BASE_DIR/$name/Project.swift" <<EOF
import ProjectDescription

let project = Project(
  name: "$name",
  settings: .settings(
    base: [
      "IPHONEOS_DEPLOYMENT_TARGET": "$ios"
    ]
  ),
  targets: [
    .target(
      name: "$name",
      destinations: .iOS,
      product: .$product,
      bundleId: "$bundle.$name_lc",
      sources: ["Sources/**"],
      resources: [],
      dependencies: [
$deps_formatted
      ]
    ),
    .target(
      name: "${name}Tests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "$bundle.${name_lc}Tests",
      sources: ["Tests/**"],
      resources: [],
      dependencies: [.target(name: "$name")]
    )
  ]
)
EOF
}

maybe_create_workspace() {
  [[ "$WORKSPACE_MODE" == "skip" ]] && { echo "• Workspace.swift: skip (no se modifica)"; return; }
  if [[ -f "Workspace.swift" ]]; then
    echo "• Workspace.swift existente: no se modifica (modo auto)."
    return
  fi
  cat > "Workspace.swift" <<EOF
import ProjectDescription

let workspace = Workspace(
  name: "$APP_NAME",
  projects: [
    "Apps/**",
    "Modules/**",
    "Dependencies/**"
  ]
)
EOF
  echo "• Workspace.swift creado (Apps/**, Modules/**, Dependencies/**)."
}

title "Creando módulo: $MODULE_NAME en $BASE_DIR/"
if [[ -d "$BASE_DIR/$MODULE_NAME" ]]; then
  echo "❌ Ya existe $BASE_DIR/$MODULE_NAME"
  exit 1
fi

create_skeleton "$MODULE_NAME"
write_project_swift "$MODULE_NAME" "$PRODUCT" "$IOS_VERSION" "$BUNDLE_BASE" "$NAME_LC" "$DEPS_CSV"
maybe_create_workspace

echo
echo "✅ Módulo '$MODULE_NAME' creado en $BASE_DIR/$MODULE_NAME"
echo "   Tipo: $PRODUCT | iOS: $IOS_VERSION"
echo "   Dependencias: ${DEPS_CSV:-ninguna}"
echo "   Workspace: $WORKSPACE_MODE"
echo
echo "Siguiente paso:"
echo "  • tuist generate"
