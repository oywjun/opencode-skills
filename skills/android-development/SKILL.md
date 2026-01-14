---
name: android-development
description: Specialized knowledge for Android system development, NDK, kernel modules, and driver development
---

# Android System Development

## Expertise Areas
- Android NDK native development
- Kernel module compilation and loading for Android
- Linux driver development for Android devices
- ADB debugging and automation
- Cross-compilation for ARM architectures
- Generic Kernel Image (GKI) development

## Key Concepts

### Kernel Module Support
- GKI (Generic Kernel Image) module loading mechanisms
- Vendor ramdisk kernel module storage (`/lib/modules/`)
- First-stage init module loading
- modprobe configuration files

### Build Systems
- Android build system (Soong/Blueprint)
- Cross-compilation toolchains for ARM/ARM64
- Kernel makefiles and configurations

### Driver Development
- Character and block device drivers
- Platform device integration
- Device tree overlays
- SELinux policies for drivers

### Debugging
- ADB logcat analysis
- Kernel message buffer (dmesg)
- Crash analysis (tombstones)
- Hardware debugging interfaces

## Common Tasks

### Building Kernel Modules
1. Configure cross-compilation toolchain
2. Use Android kernel build system or standalone compilation
3. Handle kernel version compatibility (GKI requirements)
4. Package for vendor ramdisk

### ADB Automation
- Install and uninstall applications
- Push/pull files
- Run shell commands on device
- Monitor logs in real-time
- Control device state (reboot, recovery, etc.)

### Driver Permissions
- Understand Android security model
- Configure proper SELinux contexts
- Handle device node permissions
- Manage kernel module signing (if required)

## Resources
- [Android Kernel Module Support](https://source.android.com/docs/core/architecture/kernel/kernel-module-support)
- [Linux Driver Documentation](https://www.kernel.org/doc/html/latest/driver-api/index.html)
- [NDK Documentation](https://developer.android.com/ndk)
- [AOSP Source Code](https://source.android.com/)

## When to Use This Skill
Use this skill when working on:
- Android kernel driver development
- Native code development with NDK
- Device-specific Android development
- ADB automation and testing
- Cross-compilation for Android devices

## Development Workflow
1. Understand device specifications and kernel version
2. Set up proper cross-compilation environment
3. Develop driver following Android kernel guidelines
4. Test on emulators or real devices
5. Handle SELinux permissions properly
6. Package for vendor partitions if needed
