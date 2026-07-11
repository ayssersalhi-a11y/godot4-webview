#!/usr/bin/env just --justfile

set working-directory := 'rust'

# المهمة الرئيسية التي يستدعيها GitHub Actions
# مثال: just os=android target=aarch64-linux-android build
build os target="":
    @echo "Building for {{os}} (target: {{target}})..."
    @if [ "{{os}}" == "android" ]; then \
        just _build-android "{{target}}" && just _copy-to-godot-android "{{target}}"; \
    elif [ "{{os}}" == "windows" ]; then \
        just _build-windows && just _copy-to-godot-windows "{{target}}"; \
    elif [ "{{os}}" == "macos" ]; then \
        just _build-macos; \
    else \
        just _build-linux "{{target}}" && just _copy-to-godot-linux "{{target}}"; \
    fi

# --- مهام البناء (Build) ---

_build-linux target:
    cargo build --target {{target}} --release

_build-android target:
    cargo build --target {{target}} --release

_build-windows:
    cargo build --release

_build-macos:
    cargo build --target aarch64-apple-darwin --release
    cargo build --target x86_64-apple-darwin --release
    mkdir -p ./target/release/libgodot_wry.framework/Resources
    lipo -create -output ./target/release/libgodot_wry.dylib ./target/aarch64-apple-darwin/release/libgodot_wry.dylib ./target/x86_64-apple-darwin/release/libgodot_wry.dylib
    mv ./target/release/libgodot_wry.dylib ./target/release/libgodot_wry.framework/libgodot_wry.dylib
    cp ../assets/Info.plist ./target/release/libgodot_wry.framework/Resources/Info.plist
    mkdir -p ../godot/addons/godot_wry/bin/universal-apple-darwin
    cp -R ./target/release/libgodot_wry.framework ../godot/addons/godot_wry/bin/universal-apple-darwin

# --- مهام النسخ (Copy) ---

_copy-to-godot-linux target:
    mkdir -p ../godot/addons/godot_wry/bin/{{target}}
    cp ./target/{{target}}/release/libgodot_wry.so ../godot/addons/godot_wry/bin/{{target}}/

_copy-to-godot-android target:
    mkdir -p ../godot/addons/godot_wry/bin/{{target}}
    cp ./target/{{target}}/release/libgodot_wry.so ../godot/addons/godot_wry/bin/{{target}}/

_copy-to-godot-windows target:
    mkdir -p ../godot/addons/godot_wry/bin/{{target}}
    cp ./target/release/godot_wry.dll ../godot/addons/godot_wry/bin/{{target}}/

# --- مهام مساعدة للمتوافقية ---
build-macos-universal:
    @just _build-macos

build-linux target="":
    @just os="linux" target="{{target}}" build

build-windows target="":
    @just os="windows" target="{{target}}" build

build-android target="":
    @just os="android" target="{{target}}" build
