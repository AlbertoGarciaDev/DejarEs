#!/usr/bin/env bash
set -euo pipefail

APP_NAME_DEFAULT="DejarEs"
BUNDLE_BASE_DEFAULT="com.dejares"
IOS_VERSION_DEFAULT="17.0"
PRODUCT_DEFAULT="framework"
BASE_DIR_DEFAULT="Modules"

require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Falta '$1'"; exit 1; }; }
title() { echo; echo "=== $* ==="; }

if [[ $# -lt 1 ]]; then
  echo "Uso: bash $0 <ModuleName> [--type framework|staticFramework|staticLibrary] [--deps Mod1,Mod2,...] [--ios 17.0] [--dir Modules]"
  exit 1
fi

MODULE_NAME="$1"; shift

PRODUCT="$PRODUCT_DEFAULT"
DEPS_CSV=""
IOS_VERSION="$IOS_VERSION_DEFAULT"
APP_NAME="$APP_NAME_DEFAULT"
BUNDLE_BASE="$BUNDLE_BASE_DEFAULT"
BASE_DIR="$BASE_DIR_DEFAULT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) PRODUCT="${2:-$PRODUCT_DEFAULT}"; shift 2;;
    --deps) DEPS_CSV="${2:-}"; shift 2;;
    --ios)  IOS_VERSION="${2:-$IOS_VERSION_DEFAULT}"; shift 2;;
    --bundle-base) BUNDLE_BASE="${2:-$BUNDLE_BASE_DEFAULT}"; shift 2;;
    --app-name) APP_NAME="${2:-$APP_NAME_DEFAULT}"; shift 2;;
    --dir) BASE_DIR="${2:-$BASE_DIR_DEFAULT}"; shift 2;;
    *) echo "⚠️ Opción desconocida: $1"; shift;;
  esac
done

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

gen_dep_lines() {
  local csv="$1"
  [[ -z "$csv" ]] && return 0
  IFS=',' read -ra arr <<< "$csv"
  for dep in "${arr[@]}"; do
    dep_trimmed="$(echo "$dep" | xargs)"
    [[ -z "$dep_trimmed" ]] && continue
    echo "        .project(target: \"$dep_trimmed\", path: \"../$dep_trimmed\"),"
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

ensure_workspace() {
  if [[ -f "Workspace.swift" ]]; then
    if ! grep -q 'Modules/\*\*' Workspace.swift; then
      # Inserta "Modules/**" al inicio de la lista de projects (macOS sed)
      perl -0777 -pe 's/projects:\s*\[/projects: \[\n    "Modules\/**",/s' -i '' Workspace.swift 2>/dev/null || true
      echo "• Workspace.swift actualizado para incluir \"Modules/**\""
    fi
    return
  fi
  cat > "Workspace.swift" <<EOF
import ProjectDescription

let workspace = Workspace(
  name: "$APP_NAME",
  projects: [
    "Apps/**",
    "Modules/**"
  ]
)
EOF
  echo "• Workspace.swift creado con globs (Apps/** y Modules/**)."
}

title "Creando módulo: $MODULE_NAME en $BASE_DIR/"
if [[ -d "$BASE_DIR/$MODULE_NAME" ]]; then
  echo "❌ Ya existe $BASE_DIR/$MODULE_NAME"
  exit 1
fi

create_skeleton "$MODULE_NAME"
write_project_swift "$MODULE_NAME" "$PRODUCT" "$IOS_VERSION" "$BUNDLE_BASE" "$NAME_LC" "$DEPS_CSV"
ensure_workspace

echo
echo "✅ Módulo '$MODULE_NAME' creado en $BASE_DIR/$MODULE_NAME"
echo "   Tipo: $PRODUCT | iOS: $IOS_VERSION"
echo "   Dependencias: ${DEPS_CSV:-ninguna}"
echo
echo "Siguiente paso:"
echo "  • tuist generate
"
