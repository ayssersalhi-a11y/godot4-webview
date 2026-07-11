#!/usr/bin/env just --justfile

set working-directory := 'rust'

# المهمة الرئيسية التي يستدعيها الـ GitHub Actions
build os target:
    @echo "Building for {{os}} with target: {{target}}..."
    @just _build-{{os}} "{{target}}"
    @just _copy-to-godot-{{os}} "{{target}}"

# --- مهام البناء ---
_build-linux target:
    cargo build --target {{target}} --release

_build-android target:
    cargo build --target {{target}} --release

_build-windows target:
    # الويندوز عادة يبني للمنصة الحالية مباشرة
    cargo build --release

_build-macos target:
    cargo build --target {{target}} --release
    mkdir -p ./target/{{target}}/release/libgodot_wry.framework/Resources
    mv ./target/{{target}}/release/libgodot_wry.dylib ./target/{{target}}/release/libgodot_wry.framework/libgodot_wry.dylib
    cp ../assets/Info.plist ./target/{{target}}/release/libgodot_wry.framework/Resources/Info.plist

# --- مهام النسخ (متوافقة مع مسارات GitHub Actions) ---
_copy-to-godot-linux target:
    mkdir -p ../godot/addons/godot_wry/bin/{{target}}
    cp ./target/{{target}}/release/libgodot_wry.so ../godot/addons/godot_wry/bin/{{target}}/

_copy-to-godot-android target:
    mkdir -p ../godot/addons/godot_wry/bin/{{target}}
    cp ./target/{{target}}/release/libgodot_wry.so ../godot/addons/godot_wry/bin/{{target}}/

_copy-to-godot-windows target:
    # الويندوز يستخدم مساراً ثابتاً في العادة للملفات
    mkdir -p ../godot/addons/godot_wry/bin/{{target}}
    cp ./target/release/godot_wry.dll ../godot/addons/godot_wry/bin/{{target}}/

_copy-to-godot-macos target:
    mkdir -p ../godot/addons/godot_wry/bin/{{target}}
    cp -R ./target/{{target}}/release/libgodot_wry.framework ../godot/addons/godot_wry/bin/{{target}}

# --- مهمة خاصة للماك (Universal) ---
build-macos-universal:
    @echo "Building universal macOS binary..."
    cargo build --target aarch64-apple-darwin --release
    cargo build --target x86_64-apple-darwin --release
    mkdir -p ./target/release/libgodot_wry.framework/Resources
    lipo -create -output ./target/release/libgodot_wry.dylib ./target/aarch64-apple-darwin/release/libgodot_wry.dylib ./target/x86_64-apple-darwin/release/libgodot_wry.dylib
    mv ./target/release/libgodot_wry.dylib ./target/release/libgodot_wry.framework/libgodot_wry.dylib
    cp ../assets/Info.plist ./target/release/libgodot_wry.framework/Resources/Info.plist
    mkdir -p ../godot/addons/godot_wry/bin/universal-apple-darwin
    cp -R ./target/release/libgodot_wry.framework ../godot/addons/godot_wry/bin/universal-apple-darwin
