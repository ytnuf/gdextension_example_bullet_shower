
# Gdextension Project ~ Bullet Shower


This project is a GDExtension equivalent of the demo-project "Bullet Shower", which can be found here:  
https://github.com/godotengine/godot-demo-projects/tree/master/2d/bullet_shower

The main aim of this project is to provide an example of how one could structure a GDExtension addon using CMake.

This project contains the following:
- Allowing out-source builds
- Works for both single and multi config generators
- Usage of a package manager (vcpkg)
- Using presets to build for various targets
- Cross-compiling support
- An included demo godot project to test this addon

Note this project works only for Godot v4.3


## Build Instructions

Base Requirements:
- [CMake](https://cmake.org/download/) (and a build generator)
- [git](https://git-scm.com/downloads)
- A C++ compiler toolchain

Do note you would need these things in your PATH.
If you have ever built a CMake project you would these things already installed.

Recommended:
- Ninja (this is the generator required by most of the presets listed below)
- [vcpkg](https://github.com/microsoft/vcpkg) (You need ```VCPKG_ROOT``` environmental variable set to point to the location of installed vcpkg folder. However if don't have vpckg installed, this project will fetch it for you, so it's only a recommendation.)


### How to do a simple build:
Type this:
```sh
cmake -B build/default
cmake --build build/default
```

This will build the library to the ```build/default/lib``` folder.
Open the project.godot with godot, and you can run the project with F6.

Also have a look at the ```build/_shared``` folder. This is where the gdextension file with be generated.

However most of the time you probably want to be more specific with how you build the presets (e.g. cross-compiling), this where presets come along.
### Using presets for builds:

This project has various configuration presets for a more specific build.

To build with presets:
```sh
cmake --preset config-preset-name
cmake --build --preset build-preset-name
```

Note that these presets have more specific requirements:

#### gcc-linux-x64-ninjamulti
This is the config presets used to create a native linux-x64 build.  
Additional Requires:
- GCC
- Ninja

Build Presets:
- ```debug-gcc-linux-x64-ninjamulti```
- ```release-gcc-linux-x64-ninjamulti```
- ```editor-gcc-linux-x64-ninjamulti```

#### msvc-windows-x64-msbuild
This is the config presets used to create a native windows-x64 build.  
Additional Requires:
- [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/?q=build+tools#build-tools-for-visual-studio-2022)

Build Presets:
- ```debug-msvc-windows-x64-msbuild```
- ```release-msvc-windows-x64-msbuild```
- ```editor-msvc-windows-x64-msbuild```

#### mingw64-windows-x64-ninjamulti
This is the config presets used to cross compile from a linux host for a windows-x64 target.  
Additional Requires:
- x86_64-w64-mingw32
- Ninja 

Build Presets:
- ```debug-mingw64-windows-x64-ninjamulti```
- ```release-mingw64-windows-x64-ninjamulti```
- ```editor-mingw64-windows-x64-ninjamulti```

#### emscripten-web-ninjamulti
This is the config presets used to cross compile for a web target.  
Additional Requires:
- [Emscripten](https://emscripten.org/docs/getting_started/downloads.html)
- Ninja 

Build Presets:
- ```debug-emscripten-web-ninjamulti```
- ```release-emscripten-web-ninjamulti```
- ```editor-emscripten-web-ninjamulti```

#### ndk-android-arm64-ninjamulti
This is the config presets used to cross compile for a android-arm64 target.  
Additional Requires:
- [Android NDK](https://developer.android.com/ndk/guides) (you need to set the ANDROID_NDK_HOME environment variable to the ndk folder)
- Ninja 

Build Presets:
- ```debug-ndk-android-arm64-ninjamulti```
- ```release-ndk-android-arm64-ninjamulti```
- ```editor-ndk-android-arm64-ninjamulti```


### Even more customisation

Do note that the above presets aren't the only choices, you can further customise your build if you want to.
Here are the various build options for this project:

- ```USE_CCACHE``` - if ```ON``` uses Ccache if found
- ```USE_VCPKG``` - if ```ON``` tries to find vcpkg, and fallbacks to fetching it if not found
- ```SHARED_BUILD_FOLDER_REL``` - the relative location of the gdextension file (should be the same for all builds), highly recommended leaving this as the default
- ```ENABLE_ADDITIONAL_WARNINGS``` - determines if various useful warnings are turned on
- ```ENABLE_ADDRESS_SANTISER``` - determines if ASan is used (notes requires a custom build of godot with ASan)
- ```ENABLE_UNDEFINED_BEHAVIOUR_SANTISER``` - determines if UBasn is used
- ```GDEXTENSION_TARGET_PLATFORM``` - the target feature flags


Using this one can create a custom preset in a ```CMakeUserPresets.json``` file, for example:  
(It is recommended for your preset to inherit ```.base```)


```json
{
    "configurePresets": [
        {
            "name": "my-custom-config-preset",
            "inherits": ".base",
            "cacheVariables": {
                "CMAKE_CXX_COMPILER": "clang++",
                "GDEXTENSION_TARGET_PLATFORM": "linux.x86_64",
                "ENABLE_UNDEFINED_BEHAVIOUR_SANTISER": "ON",
                "USE_CCACHE": "ON"
            }
        }
    ],
    "buildPresets": [
        {
            "name": "my-custom-build-preset",
            "configurePreset": "my-custom-config-preset",
            "configuration": "Editor"
        }
    ]
}
```

## Other Example Projects:  

https://github.com/asmaloney/GDExtensionTemplate

https://github.com/vorlac/godot-roguelite


## Screenshots

![No collision](screenshots/no_collision.png)

![Collision](screenshots/collision.png)

---
Note for vs-code users:  
You may want to add ```"cmake.copyCompileCommands": "${workspaceFolder}/compile_commands.json"``` to your workspace settings (```.vscode/settings.json```) for clangd to work properly
