# Adapter types lib for pEp

## What is it

This is both a framework and a static library containing public types that are used by the pEp Objective-C Adapter.

It's your choice whether you want to use it as a framework or a static library.

## How to use it

This works best in an existing work space. Another recommendation is to check out the project relative to yours, e.g. into a subfolder, or as a sibling under the same parent directory. You will need the relative path later if you decide to use it as a static library.

Drag the project file `pEpObjCAdapterTypes.xcodeproj` into your workspace. If you don't have a workspace, drag this directly into your project.

### As a framework

* In your project, in your target, under "Build Phases", add `PEPObjCAdapterTypesFramework.framework`. Done.
* In a Swift source files, reference it with `import PEPObjCAdapterTypesFramework`.
* In Objective-C project sources, import it like this:

  ```objc
  #import <PEPObjCAdapterTypesFramework/PEPObjCAdapterTypesFramework.h>
  ```

### As a static library

* In your project, in your target, under "Build Phases", add `libpEpObjCAdapterTypes.a`.
* In "Build Settings", under "Search Paths", add the headers to your "Header Search Paths". The exact value depends on your setup, but it will probably look similar to this: `$(PROJECT_DIR)/../pEpObjCAdapter/Submodules/pEpObjCAdapterTypes/pEpObjCAdapterTypes/Public`.
* If you want to use it from a Swift project, you'll need to add an import to your bridging header:

    ```objc
    #import "PEPObjCAdapterTypes.h"
    ```

* In an objective-c project you can import the types anywhere as needed, just like in the bridging header above.
