# QEMU
## tree
```
qemu
├── android
│   ├── android-emu
│   │   └── android
│   │       └── skin
│   │           ├── agent
│   │           │   ├── agent.h
│   │           │   ├── def.h
│   │           │   └── version.h
│   │           ├── android_keycodes.h
│   │           ├── event.h
│   │           ├── keycode.h
│   │           ├── linux_keycodes.h
│   │           └── rect.h
│   └── android-emu-base
│       └── android
│           ├── base
│           │   ├── Compiler.h
│           │   ├── CpuTime.h
│           │   ├── Debug.h
│           │   ├── EnumFlags.h
│           │   ├── Log.h
│           │   ├── Optional.h
│           │   ├── StringView.h
│           │   ├── TypeTraits.h
│           │   ├── synchronization
│           │   │   └── Lock.h
│           │   └── system
│           │       └── System.h
│           └── utils
│               ├── compiler.h
│               ├── debug.h
│               └── log_severity.h
├── bin64
│   ├── e2fsck
│   └── resize2fs
└── lib64
    ├── libOpenglRender.dylib
    ├── libemugl_common.dylib
    ├── libqemu-system-anvirt-emu.dylib
    ├── libshadertranslator.dylib
    └── vulkan
        └── libvulkan.dylib

14 directories, 28 files
```

## debug
* backup origin qemu prebuilts
* run `make debug`