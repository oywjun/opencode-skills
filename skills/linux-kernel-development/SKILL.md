---
name: linux-kernel-development
description: Linux kernel driver development, module programming, and embedded systems expertise
---

# Linux Kernel Development

## Expertise Areas
- Linux kernel module programming
- Character and block device drivers
- Platform and bus drivers (I2C, SPI, GPIO)
- Interrupt handling and concurrency
- Memory management and DMA
- Embedded Linux systems
- Cross-compilation for ARM/RISC-V

## Key Concepts

### Kernel Architecture
- Process context vs. interrupt context
- Kernel space vs. user space boundaries
- Atomic operations and spinlocks
- Wait queues and completion events
- Work queues and kernel threads

### Driver Types
- **Character devices**: Sequential access devices (serial ports, LEDs)
- **Block devices**: Random access storage (SSD, eMMC)
- **Network devices**: Packet processing interfaces
- **Platform devices**: Device tree defined hardware
- **USB drivers**: USB protocol and gadget framework

### Memory Management
- kmalloc/kfree for kernel memory allocation
- vmalloc for large allocations
- DMA mapping and scatter-gather
- Page cache and buffer heads
- Copy-on-write mechanisms

### Concurrency
- Spinlocks: Short critical sections, preemption disabled
- Mutexes: May sleep, longer critical sections
- Semaphores: General-purpose counting
- RCU (Read-Copy-Update): Read-mostly data
- Per-CPU variables: Lock-free data access

## Common Tasks

### Writing a Character Device Driver
```c
// Basic structure
struct file_operations my_fops = {
    .owner = THIS_MODULE,
    .read = my_read,
    .write = my_write,
    .open = my_open,
    .release = my_release,
};
```

### Handling Interrupts
- Request IRQs with proper flags (IRQF_SHARED, etc.)
- Top half: Fast, minimal processing in ISR
- Bottom half: Deferred work (tasklet/workqueue)
- Shared interrupt handling for multiple devices

### Device Tree Integration
- Define hardware in DTS (device tree source)
- Bind drivers using compatible strings
- Parse OF (Open Firmware) properties
- Handle platform device registration

### Cross-Compilation
```bash
# ARM example
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
# ARM64 example
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
```

## Development Workflow

1. **Setup Environment**
   - Install kernel headers and build tools
   - Configure cross-compilation toolchain
   - Get kernel source or headers for target

2. **Write Driver**
   - Follow kernel coding style (checkpatch.pl)
   - Use proper kernel APIs (no libc functions)
   - Handle errors and edge cases
   - Document with kerneldoc format

3. **Build**
   - Create Makefile for module compilation
   - Cross-compile for target architecture
   - Sign module if kernel requires it

4. **Test**
   - Load with insmod/modprobe
   - Check dmesg for errors
   - Test all driver operations
   - Verify memory safety (valgrind not applicable, use kmemleak)

5. **Debug**
   - Use printk/trace_printk for logging
   - ftrace for function tracing
   - crash for kernel debugging
   - perf for performance analysis

## Important Files and APIs

- **module_init/module_exit**: Module entry/exit points
- **cdev_init/cdev_add**: Character device registration
- **request_irq/free_irq**: Interrupt management
- **kmalloc/kfree**: Dynamic memory allocation
- **copy_to_user/copy_from_user**: User-space data transfer
- **device_create/device_destroy**: Device node creation

## Resources
- [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- [Linux Device Drivers Book (LDD3)](https://lwn.net/Kernel/LDD3/)
- [Kernel Driver API](https://www.kernel.org/doc/html/latest/driver-api/index.html)
- [Kernel Development HOWTO](https://www.kernel.org/doc/html/latest/process/howto.html)

## When to Use This Skill
Use this skill when:
- Writing or debugging Linux kernel drivers
- Developing embedded Linux system software
- Cross-compiling kernel modules
- Working with hardware interfaces (GPIO, I2C, SPI, etc.)
- Optimizing kernel code for performance
- Debugging kernel panics and crashes

## Best Practices

- Never sleep with spinlock held
- Always check return values
- Handle all error conditions
- Use proper locking for shared data
- Prefer workqueues over tasklets for long-running tasks
- Validate all user-space inputs
- Test on multiple kernel versions if compatibility needed
- Use kernel's memory allocation functions, not libc malloc
