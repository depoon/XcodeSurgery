
![Image of XcodeSurgery](docs/XcodeSurgeryLogo_v2.png)
# XcodeSurgery

XcodeSurgery is a swift XCode build phase CLI tool for copying compiled binaries between iOS app targets. 

## The downside with using `xcconfig` or `preprocessor macros` to manage build variants
Building different build variants using configuration will trigger recompilation as the build processes do not share common `$(TARGET_BUILD_DIR)`. Changing preprocessor macro values will trigger dependency graph reanalysis and recompilation of codes. Ideally there should not be recompilation if there's no change in the logic of the source codes.

## Solution: Create a placeholder target and swap binaries.
XcodeSurgery aims to eliminate unnecessary recompilation of source codes when building different flavours or variants of an iOS app target.

## Installing XCodeSurgery


XcodeSurgery is available through Mint 🌱.
```sh
mint install depoon/XcodeSurgery
```

Mint can be installed via Homebrew
```sh
brew install mint
```

## Steps to Setup XcodeSurgery in your Project
1. Create a new app target. We will refer this as the `Destination Target` and the original target as the `Source Target`
2. Copy Build Settings of `Source Target` over to `Destination Target`.
3. Add Preparation Build Phase for `Source Target`
4. Add Transplant Build Phase for `Destination Target`
5. Build the `Source Target`
```sh
xcodesurgery prepare \
--workingDirectory "${SRCROOT}/surgeryroom" \
--targetBuildDirectory ${TARGET_BUILD_DIR} \
--targetName "${TARGETNAME}"
```
6. Build the `Destination Target`
```sh
xcodesurgery prepare \
--workingDirectory "${SRCROOT}/surgeryroom" \
--targetBuildDirectory ${TARGET_BUILD_DIR} \
--targetName "${TARGETNAME}"
```


