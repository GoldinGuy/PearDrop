REM ANDROID_NDK_HOME is already set and pointing to the Android NDK folder

REM ENV
set CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=%ANDROID_NDK_HOME%/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android26-clang
set CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER=%ANDROID_NDK_HOME%/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi26-clang
set CARGO_TARGET_I686_LINUX_ANDROID_LINKER=%ANDROID_NDK_HOME%/toolchains/llvm/prebuilt/darwin-x86_64/bin/i686-linux-android26-clang

REM Build
cargo build --target aarch64-linux-android --release
cargo build --target armv7-linux-androideabi --release
cargo build --target i686-linux-android --release
