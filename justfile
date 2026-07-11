
#!/usr/bin/env just --justfile

# تحديد نظام التشغيل والهدف الافتراضي
os := if os() == "macos" { "macos" } else if os() == "windows" { "windows" } else if os() == "android" { "android" } else { "linux" }
target := if os == "macos" { arch() + "-apple-darwin" } else if os == "windows" { arch() + "-pc-windows-msvc" } else if os == "android" { arch() + "-linux-android" } else { arch() + "-unknown-linux-gnu" }

default: build

set working-directory := 'rust'

# مهمة البناء الذكية التي تقبل أي target وتوجهها للمهمة الصحيحة
build target_override="":
	@echo "Building for {{os}} ({{if target_override == "" { target } else { target_override }}})..."
	@if [ "{{os}}" = "android" ]; then just _build-android; \
	elif [ "{{os}}" = "windows" ]; then just _build-windows; \
	elif [ "{{os}}" = "macos" ]; then just _build-macos; \
	else just _build-linux; fi
	@if [ "{{os}}" = "android" ]; then just _copy-to-godot-android; \
	elif [ "{{os}}" = "windows" ]; then just _copy-to-godot-windows; \
	elif [ "{{os}}" = "macos" ]; then just _copy-to-godot-macos; \
	else just _copy-to-godot-linux; fi

copy-to-godot: build
	@echo "Copying files to Godot project..."
	@just _copy-to-godot-{{os}}

clean:
	cargo clean

# مهام البناء المنفصلة
_build-macos:
	cargo build --target {{target}} --release
	mkdir -p ./target/{{target}}/release/libgodot_wry.framework/Resources
	mv ./target/{{target}}/release/libgodot_wry.dylib ./target/{{target}}/release/libgodot_wry.framework/libgodot_wry.dylib
	cp ../assets/Info.plist ./target/{{target}}/release/libgodot_wry.framework/Resources/Info.plist

_build-linux:
	cargo build --target {{target}} --release

_build-windows:
	cargo build --release

_build-android:
	cargo build --target {{target}} --release

# مهام النسخ المنفصلة
_copy-to-godot-macos target:
	mkdir -p ../godot/addons/godot_wry/bin/{{target}}
	cp -R ./target/{{target}}/release/libgodot_wry.framework ../godot/addons/godot_wry/bin/{{target}}

_copy-to-godot-linux target:
	mkdir -p ../godot/addons/godot_wry/bin/{{target}}
	cp ./target/{{target}}/release/libgodot_wry.so ../godot/addons/godot_wry/bin/{{target}}/

_copy-to-godot-windows target:
	mkdir -p ../godot/addons/godot_wry/bin/{{target}}
	cp ./target/release/godot_wry.dll ../godot/addons/godot_wry/bin/{{target}}/

_copy-to-godot-android target:
	mkdir -p ../godot/addons/godot_wry/bin/{{target}}
	cp ./target/{{target}}/release/libgodot_wry.so ../godot/addons/godot_wry/bin/{{target}}/

# مهام التصدير الكبرى
build-all: build-macos-universal build-linux build-windows

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

build-linux:
	@just os="linux" build

build-windows:
	@just os="windows" build

build-android:
	@just os="android" build

# --- مهام مساعدة لمنع أخطاء GitHub Actions ---
universal-apple-darwin:
	@echo "Universal Apple Darwin target passed from CI"

x86_64-pc-windows-msvc:
	@just build-windows
