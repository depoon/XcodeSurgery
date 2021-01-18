
# Frequently Asked Questions

### Does XcodeSurgery has dSYM support?
Yes. The `prepare` command will attempt to copy any generated source-target dSYM files to the specified working directory. In the `transplant` comment, you will need to supply the `debugInformationFormat` argument with `${DEBUG_INFORMATION_FORMAT}` (dwarf-with-dsym) environment value. The transplant command will then attempt to replace the `DWARF` debug symbols file accordingly.

If you are creating build variants with no code changes, the debug symbols mapping for the source and destination targets dSYM files should not differ. As the `transplant` command is reusing both the source target's app binary and dSYM files, the destination app binary and dSYM file will also have the same matching uuid pair.


### I am getting errors because my app does not use Scene Delegate.
Apps created prior to iOS 13 will run into this issue as Xcode will now use UISceneDelegate for new targets. To make the new target compatible with the source target app, you will need to perform the following:
1. Completely remove the “Application Scene Manifest” entry from Info.plist.
2. If there is a scene delegate class, remove it.
3. If there are any scene related methods in your app delegate, remove those methods.
4. If missing, add the property `var window: UIWindow?` to your app delegate.

### We are still compiling source codes for each variant
Yes we are. We merely using the destination target as a placeholder. As there is minimal source codes, the time taken to compile the codes is insignificant. In fact you can also choose to remove all source codes attached to the destination target.

### The app variant is not picking up the correct icon.
Xcode requires the `Assets.xcassets` to be available to the destination target before it adds the app icon entries into the Info.plist file. All is required is to select `Assets.xcassets` in the project navigator and select the destination target membership.


