# OpenWrt<!-- omit in toc -->

- [1. Instruction of OpenWrt](#1-instruction-of-openwrt)
- [2. Different download methods](#2-different-download-methods)
  - [2.1. Select firmware for a specific hardware](#21-select-firmware-for-a-specific-hardware)
  - [2.2. Firmware selector and customized settings](#22-firmware-selector-and-customized-settings)
  - [2.3. Stable release](#23-stable-release)
  - [2.4. All releases](#24-all-releases)
- [3. Different firmware variants](#3-different-firmware-variants)
  - [3.1. `generic-ext4-combined-efi.img.gz`](#31-generic-ext4-combined-efiimggz)
  - [3.2. `generic-ext4-combined.img.gz`](#32-generic-ext4-combinedimggz)
  - [3.3. `generic-ext4-rootfs.img.gz`](#33-generic-ext4-rootfsimggz)
  - [3.4. `generic-squashfs-combined-efi.img.gz`](#34-generic-squashfs-combined-efiimggz)
  - [3.5. `generic-squashfs-combined.img.gz`](#35-generic-squashfs-combinedimggz)
  - [3.6. `generic-squashfs-rootfs.img.gz`](#36-generic-squashfs-rootfsimggz)
  - [3.7. `rootfs.tar.gz`](#37-rootfstargz)
  - [3.8. summary](#38-summary)
- [4. ext4 and SquashFS image types](#4-ext4-and-squashfs-image-types)
  - [4.1. SquashFS Image](#41-squashfs-image)
    - [4.1.1. How it works in OpenWrt](#411-how-it-works-in-openwrt)
    - [4.1.2. Advantages of SquashFS](#412-advantages-of-squashfs)
    - [4.1.3. Disadvantages of SquashFS](#413-disadvantages-of-squashfs)
  - [4.2. ext4 Image](#42-ext4-image)
    - [4.2.1. How it works in OpenWrt](#421-how-it-works-in-openwrt)
    - [4.2.2. Advantages of ext4](#422-advantages-of-ext4)
    - [4.2.3. Disadvantages of ext4](#423-disadvantages-of-ext4)
  - [4.3. Summary](#43-summary)
  - [4.4. Terminology](#44-terminology)
    - [4.4.1. JFFS2 / UBIFS](#441-jffs2--ubifs)
    - [4.4.2. NOR / NAND flash](#442-nor--nand-flash)
- [5. Image type](#5-image-type)

## 1. Instruction of OpenWrt

[OpenWrt](https://openwrt.org/): **Wrt** stands for **W**ireless **r**ou**t**er.

## 2. Different download methods

### 2.1. Select firmware for a specific hardware

You can search in [Table of Hardware: Firmware downloads](https://openwrt.org/toh/views/toh_fwdownload) page to figure out if there are some specific firmware that can be used in your hardware.

### 2.2. Firmware selector and customized settings

In [firmware-selector](https://firmware-selector.openwrt.org/) page, you can select a firmware and do some customized settings for the selector. Specifically, you can "**Customize installed packages and/or first boot script**".

In [Expanding root partition and filesystem](https://openwrt.org/docs/guide-user/advanced/expand_root?s[]=resize), it explains how to expand OpenWrt root partition and filesystem on x86 target.

You can use [firmware-selector](https://firmware-selector.openwrt.org/) page to pre-install required packages in your customized firmware, then you can use them to resize the filesystem more convenient.

### 2.3. Stable release

In [OpenWrt Downloads](https://downloads.openwrt.org/) page, you can find the most recent release.

### 2.4. All releases

Skilled users can also select firmware in [Index of (root) / releases](https://downloads.openwrt.org/releases/) page which contains all releases.

## 3. Different firmware variants

> OpenWrt Downloads page [https://downloads.openwrt.org/](https://downloads.openwrt.org/)

There are many kinds of firmware, let's take x86_64 target as example, here is the firmware list extracted from [this](https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/) link:

- generic-ext4-combined-efi.img.gz
- generic-ext4-combined.img.gz
- generic-ext4-rootfs.img.gz
- generic-squashfs-combined-efi.img.gz
- generic-squashfs-combined.img.gz
- generic-squashfs-rootfs.img.gz
- rootfs.tar.gz

Let's break down each of these OpenWrt image types, focusing on their purpose and typical use cases, particularly for the `generic` (x86/x86-64) target.

All of these are compressed with `gzip` (indicated by `.gz`), so you'll need to decompress them first before writing to a disk or using in a VM.

### 3.1. `generic-ext4-combined-efi.img.gz`

- **Type:** Combined disk image with an `ext4` root filesystem, designed for **UEFI** booting.
- **Contents:** Includes the OpenWrt kernel, bootloader (configured for UEFI), and the entire root filesystem formatted as `ext4`. It's a full disk image, meaning it contains partition tables and all necessary boot information.
- **Characteristics:**
  - **Ext4 Root:** The entire root partition is writable and formatted with `ext4`. This allows you to use the full capacity of your target disk (e.g., USB drive, SSD) for installing packages, storing logs, and other data. There's no separate read-only base.
  - **UEFI Boot:** Configured to boot on modern systems that use UEFI firmware.
  - **Combined:** Self-contained and ready to be written directly to a raw disk.
- **Use Cases:**
  - **Preferred for modern x86 PCs/mini-PCs:** If you're installing OpenWrt on a physical computer with UEFI firmware and want to utilize the full disk space for OpenWrt.
  - **Virtual Machines (UEFI):** Suitable for creating UEFI-based VMs in hypervisors that can import raw disk images (though specific VM formats like `.qcow2` are often more convenient).
- **How to Use:** Decompress the `.gz` file. Then, use `dd` (Linux/macOS) or a tool like Rufus/Win32 Disk Imager (Windows) to write the `.img` file to a USB stick or an SSD. You'll boot your system in UEFI mode.

### 3.2. `generic-ext4-combined.img.gz`

- **Type:** Combined disk image with an `ext4` root filesystem, designed for **BIOS** (Legacy) booting.
- **Contents:** Similar to `generic-ext4-combined-efi.img.gz`, but the bootloader is configured for older BIOS (or Legacy BIOS compatibility mode on UEFI systems). It contains the kernel, bootloader, and an `ext4` root filesystem.
- **Characteristics:**
  - **Ext4 Root:** Full writable `ext4` root partition.
  - **BIOS Boot:** Configured to boot on systems using traditional BIOS firmware.
  - **Combined:** Self-contained and ready to be written directly to a raw disk.
- **Use Cases:**
  - **Older x86 PCs/mini-PCs:** For systems that only support BIOS booting.
  - **Virtual Machines (BIOS):** For creating BIOS-based VMs.
- **How to Use:** Decompress the `.gz` file. Use `dd` or a similar disk imager tool to write the `.img` file to your target disk. Boot your system in BIOS mode.

### 3.3. `generic-ext4-rootfs.img.gz`

- **Type:** Raw image containing **only** the `ext4` root filesystem.
- **Contents:** This file is literally just the `ext4` filesystem. It does **not** include the kernel, bootloader, or partition tables.
- **Characteristics:**
  - **Ext4 Root:** Writable `ext4` filesystem.
  - **Not Bootable on its own:** You cannot directly flash this to a disk and expect it to boot. It's just a filesystem partition image.
- **Use Cases:**
  - **Custom Installations:** When you want to manually create partitions, install your own bootloader (like GRUB), and then place the OpenWrt root filesystem onto one of those partitions.
  - **Chroot Environments:** For setting up an OpenWrt environment within an existing Linux system.
  - **Disk Image Modification:** If you're building a custom disk image and want to inject a pre-made root filesystem.
- **How to Use:** Typically, you would write this image to a pre-existing partition after manually setting up the kernel and bootloader on another partition.

### 3.4. `generic-squashfs-combined-efi.img.gz`

- **Type:** Combined disk image with a `SquashFS` root filesystem and an overlay, designed for **UEFI** booting.
- **Contents:** Includes the kernel, UEFI bootloader, the read-only `SquashFS` partition, and a small writable partition (often `ext4` on x86, used as the OverlayFS upper layer).
- **Characteristics:**
  - **SquashFS Root with OverlayFS:** The base system is read-only `SquashFS` for robustness and compression. All your changes and installed packages are stored in a separate, writable overlay (which is `ext4` on x86 generic targets). `OverlayFS` merges these two.
  - **"Factory Reset" Capable:** You can easily revert to the original OpenWrt state by erasing the overlay partition.
  - **UEFI Boot:** Configured for UEFI systems.
  - **Combined:** Self-contained and ready to be written to a raw disk.
- **Use Cases:**
  - **Robust Installations:** If you want the reliability and easy reset capabilities of the standard OpenWrt setup on a modern x86 machine.
  - **Test Environments:** Great for testing configurations, as you can easily reset if something goes wrong.
  - **VMs (UEFI):** Suitable for UEFI-based VMs if you prefer this filesystem layout.
- **How to Use:** Decompress and write the `.img` file to your target disk using `dd` or a disk imager. Boot your system in UEFI mode.

### 3.5. `generic-squashfs-combined.img.gz`

- **Type:** Combined disk image with a `SquashFS` root filesystem and an overlay, designed for **BIOS** booting.
- **Contents:** Similar to `generic-squashfs-combined-efi.img.gz`, but with a BIOS-compatible bootloader. It includes the kernel, BIOS bootloader, `SquashFS` base, and writable overlay.
- **Characteristics:**
  - **SquashFS Root with OverlayFS:** Read-only base with writable overlay.
  - **"Factory Reset" Capable:** Easy to revert.
  - **BIOS Boot:** Configured for traditional BIOS systems.
  - **Combined:** Self-contained and ready for raw disk writing.
- **Use Cases:**
  - **Older x86 PCs/mini-PCs:** For systems that only support BIOS booting, where you want the robust OpenWrt filesystem.
  - **VMs (BIOS):** For creating BIOS-based VMs if you prefer this filesystem layout.
- **How to Use:** Decompress and write the `.img` file to your target disk. Boot your system in BIOS mode.

### 3.6. `generic-squashfs-rootfs.img.gz`

- **Type:** Raw image containing **only** the `SquashFS` root filesystem (with the overlay mechanism assumed).
- **Contents:** Just the compressed, read-only `SquashFS` filesystem itself. No kernel, bootloader, or partition information.
- **Characteristics:**
  - **SquashFS Root:** The read-only SquashFS partition.
  - **Not Bootable on its own:** Like `generic-ext4-rootfs.img.gz`, this is not a bootable image directly.
- **Use Cases:**
  - **Custom Installations:** For scenarios where you manually handle kernel loading and partition setup, then place this SquashFS onto a dedicated partition.
  - **Building Custom Firmware:** As a component in a more complex custom firmware build process.
- **How to Use:** Requires advanced manual setup to integrate into a bootable system.

### 3.7. `rootfs.tar.gz`

- **Type:** A standard **tar archive** of the root filesystem.
- **Contents:** Contains all the files and directories that make up the OpenWrt root filesystem, compressed into a tarball. It does **not** include the kernel, bootloader, or any disk-specific layout (like partition tables).
- **Characteristics:**
  - **Flexible Format:** Can be extracted anywhere on a compatible Linux filesystem.
  - **Not Directly Bootable:** Cannot be directly booted from, as it lacks a kernel and bootloader.
- **Use Cases:**
  - **Chroot Environments:** Excellent for creating an OpenWrt chroot environment within an existing Linux system for development or testing.
  - **Manual Installations:** For very specific, highly customized installations where you want to manually populate a partition with the OpenWrt files.
  - **Containerization:** As a base for OpenWrt in a container (e.g., LXC).
- **How to Use:** Decompress (`tar -xzf rootfs.tar.gz`) and extract the contents to a target directory or partition. You would then need to manually configure the kernel and boot process to use this root filesystem.

---

### 3.8. summary

**In summary:**

- **`combined.img.gz` files are for direct disk writing and booting.** Choose `efi` for UEFI, no `efi` for BIOS.
- **`ext4` gives you full disk writability.**
- **`squashfs` gives you the robust, resettable OpenWrt overlay system.**
- **`rootfs.img.gz` and `rootfs.tar.gz` are for advanced, manual, or custom setups.**

For most users installing OpenWrt on a PC or VM, you'll likely want one of the `combined` images, choosing `ext4` for maximum flexibility or `squashfs` for the traditional OpenWrt robustness, and matching `efi` or non-`efi` to your system's boot mode.

## 4. ext4 and SquashFS image types

### 4.1. SquashFS Image

> For embedded devices with limited flash memory

SquashFS is a **compressed, read-only filesystem**. It's the default and most common filesystem used for OpenWrt images, especially on embedded devices with limited flash memory (like most routers).

#### 4.1.1. How it works in OpenWrt

OpenWrt employs a clever trick to make a read-only SquashFS partition appear writable to the user. It uses an **OverlayFS** (or a similar mechanism like `mini_fo`) to combine the read-only SquashFS root filesystem with a small, writable *JFFS2* (or *UBIFS for NAND flash*) partition.

- `/rom` (**SquashFS**): This is the base, *read-only* part of the filesystem. It contains the core OpenWrt system, pre-installed packages, and default configurations.
- `/overlay` (**JFFS2**/**UBIFS**): This is a small, *writable* partition where all changes, new packages, and custom configurations are stored.
- `/` (**OverlayFS**): The user sees a single, merged filesystem at `/` where changes appear to be applied directly. When you modify a file that exists in `/rom`, a copy of that file is placed in `/overlay` and the system uses the modified version.

#### 4.1.2. Advantages of SquashFS

- **Space Efficiency**: Due to compression, **SquashFS** images are significantly smaller than uncompressed filesystems, which is vital for devices with limited flash memory.
- **Resilience and "Factory Reset" Capability**: Because the base system on SquashFS is read-only, it's very robust. If your writable `/overlay` partition gets corrupted or you mess up your configuration, you can easily perform a "factory reset" by simply erasing the `/overlay` partition. This reverts the system to its initial state from the read-only SquashFS, providing a reliable recovery mechanism.
- **Speed**: Reading from a compressed filesystem can sometimes be faster, especially if the decompression is optimized and the underlying storage is slow.

#### 4.1.3. Disadvantages of SquashFS

- **Limited Writable Space**: The `/overlay` partition is typically **small**. While sufficient for common configurations and a few extra packages, it can become a limitation if you want to install many large packages or store a lot of data.
- **"Wasted" Space on Modifications**: When a file in the read-only SquashFS is modified, the original file remains in SquashFS, and a modified copy is created in `/overlay`. This means you effectively have two copies of the file, consuming more space in `/overlay` than if the file was directly modified on a fully writable filesystem.
- **Less Flexible Partition Resizing**: While it's possible to expand the root filesystem with SquashFS, it's often more complex than with a pure ext4 setup, as you're dealing with two distinct filesystems (**SquashFS** and **JFFS2**/**UBIFS**) and the **OverlayFS** mechanism.

### 4.2. ext4 Image

> Often for x86 and Devices with Larger Storage

`ext4` is a journaling filesystem widely used in Linux distributions. In OpenWrt, `ext4` images are typically found for platforms with larger storage, such as x86-based systems (e.g., **mini PCs**, **VMs**) or single-board computers (SBCs) that boot from SD cards or eMMC.

#### 4.2.1. How it works in OpenWrt

An `ext4` image usually means the entire root filesystem is a single, writable ext4 partition. There's no separate read-only *base* or *overlay*.

#### 4.2.2. Advantages of ext4

- **Full Writable Space**: The entire partition space allocated to `ext4` is available for installation of packages, logs, and user data. This is a significant advantage for devices with large storage, as you can easily utilize the full capacity of an SD card or SSD.
- **Simpler Management**: Since it's a single, writable filesystem, operations like resizing the root partition to fill the entire disk are generally simpler and more straightforward than with *SquashFS* + *OverlayFS*.
- **Better for Data-Intensive Applications**: If you plan to run applications that generate a lot of logs, store large files (e.g., Docker containers, file sharing services), or install many packages, `ext4` is usually a better choice due to its direct access to all available storage.
- **No "Wasted" Space from Modifications**: Files are modified in place, so there's no duplication of files as seen with the OverlayFS model.

#### 4.2.3. Disadvantages of ext4

- **No Built-in "Factory Reset" via File System**: Unlike SquashFS, there's no inherent "factory reset" mechanism by simply erasing an overlay. If you corrupt your `ext4` filesystem or configuration, a full reflash of the image is usually required to restore the system to a clean state. You'd need to manually backup/restore configurations.
- **Larger Image Size**: `ext4` images are uncompressed, making them larger than equivalent SquashFS images. This isn't an issue for x86 or SBCs with ample storage but makes them unsuitable for routers with tiny flash memory.
- **Less Robust Against Corruption (Compared to Read-Only)**: While `ext4` is a robust journaling filesystem, a power loss or system crash during a write operation could potentially lead to filesystem corruption, requiring manual recovery tools (`fsck`). The read-only nature of SquashFS offers a higher degree of inherent resilience for the core system.

### 4.3. Summary

| Feature              | SquashFS Image                                  | ext4 Image                                     |
|:---------------------|:------------------------------------------------|:-----------------------------------------------|
| **Root Filesystem**  | Compressed, Read-Only (with Writable Overlay)   | Writable                                       |
| **Storage Layout**   | `/rom` (SquashFS) + `/overlay` (JFFS2/UBIFS)    | Single `ext4` partition                        |
| **Space Efficiency** | High (due to compression)                       | Lower (uncompressed)                           |
| **Writable Space**   | Limited (only `/overlay`)                       | Full partition capacity                        |
| **"Factory Reset"**  | Easy (erase `/overlay`)                         | Requires re-flashing or manual restore         |
| **Resilience**       | High (core is read-only)                        | Standard (journaling helps, but not read-only) |
| **Use Cases**        | Most routers, embedded devices with small flash | x86, SBCs, devices with large storage          |
| **Complexity**       | OverlayFS can be conceptually more complex      | Simpler, direct filesystem                     |

### 4.4. Terminology

#### 4.4.1. JFFS2 / UBIFS

**JFFS2(Journalling Flash File System version 2)** , It's a specialized file system designed specifically for use with flash memory devices, particularly in embedded systems like routers (where OpenWrt is commonly used).

Despite the emergence of UBIFS, JFFS2 remains widely used in many embedded systems, particularly for smaller **NOR flash devices** where its simplicity and robustness are still highly valued.

**UBIFS(Unsorted Block Image File System)** , a prominent successor of JFFS2 .

UBIFS is a modern, log-structured file system specifically designed for larger unmanaged NAND flash memory devices. It was developed by Nokia engineers and made its way into the Linux kernel (2.6.27 and later).

While JFFS2 was a groundbreaking flash file system, UBIFS addresses many of its limitations, particularly for larger NAND flash storage, making it a "next-generation" solution.

**The UBI Layer: The Foundation of UBIFS**

A key distinguishing feature of UBIFS is that it doesn't directly interact with the raw flash (*Memory Technology Device - MTD*). Instead, it sits on top of an intermediate layer called **UBI (Unsorted Block Images)**. This two-layer architecture is fundamental to UBIFS's advantages.

In essence, UBIFS, by leveraging the UBI layer, provides a more robust, performant, and scalable flash file system solution compared to JFFS2, particularly well-suited for modern NAND flash-based embedded systems.

| Feature                 | UBIFS                                                    | JFFS2                                                       |
|:------------------------|:---------------------------------------------------------|:------------------------------------------------------------|
| **Underlying Layer**    | UBI (handles wear leveling, bad blocks)                  | MTD (handles raw flash, JFFS2 does its own wear leveling)   |
| **Mount Time**          | Much faster (on-media index, fastmap)                    | Slower (scans entire flash to build in-memory index)        |
| **Memory Consumption**  | Lower (index on media)                                   | Higher (index built in RAM)                                 |
| **Scalability**         | Scales much better with larger flash sizes               | Performance degrades with larger flash                      |
| **Write Performance**   | Generally faster (write-back caching, UBI optimizations) | Slower (write-through)                                      |
| **Volume Management**   | Built-in (via UBI)                                       | No direct volume management                                 |
| **Bad Block Handling**  | Transparently handled by UBI layer                       | Handled by JFFS2 itself (can be less robust for large NAND) |
| **Wear Leveling Scope** | Global across all UBI volumes                            | Per-JFFS2 partition                                         |

#### 4.4.2. NOR / NAND flash

- **NOR(Not OR)** flash: Its name comes from the way its memory cells are arranged, which resembles a NOR logic gate.
- **NAND(Negative-AND)** flash: Its name comes from the series connection of its memory cells, which resembles a NAND logic gate.

| Feature           | NOR Flash                                           | NAND Flash                                            |
| :---------------- | :-------------------------------------------------- | :---------------------------------------------------- |
| **Architecture** | Cells connected in **parallel** (like NOR gate)     | Cells connected in **series** (like NAND gate)        |
| **Access Type** | Random access (byte-addressable)                    | Sequential access (page/block addressable)            |
| **Read Speed** | **Very Fast** (for random reads, XIP)               | Slower (for random reads), **Faster for sequential** |
| **Write/Erase Speed** | Slower (byte/word-level write, larger block erase) | **Faster** (page write, block erase)                  |
| **Execute-In-Place (XIP)** | **Yes** (code can run directly from flash)      | **No** (code must be "shadowed" to RAM first)         |
| **Density** | Lower (larger cell size, more complex wiring)       | **Higher** (smaller cell size, simpler wiring)        |
| **Cost per Bit** | Higher                                              | **Lower** |
| **Reliability** | Very High (fewer bit errors, less prone to bad blocks) | Good (requires ECC for error correction)              |
| **Bad Blocks** | Generally ships with 0 bad blocks, rarely develops new ones | Can ship with bad blocks, prone to developing more    |
| **Endurance (P/E Cycles)** | Higher (e.g., 100K-1M)                            | Lower (e.g., 500-10K for MLC/TLC, 100K+ for SLC/3D)   |
| **Wear Leveling** | Less critical (managed by file system if needed)    | **Crucial** (managed by FTL/UBI to prolong life)      |
| **Management** | Simpler, often direct interface                     | More complex (requires FTL, UBI layer, ECC)           |
| **Typical Capacity** | MBs to a few GBs                                  | **GBs to TBs** |
| **Common Use Cases** | Boot code (BIOS/firmware), embedded code, small OS, network router firmware, microcontrollers, IoT devices | Mass storage (SSDs, USB drives, SD cards), smartphones, tablets, high-capacity data logging |

In conclusion, NOR flash is the workhorse for **code execution and low-capacity, high-reliability firmware storage**, where fast random reads and XIP are essential. NAND flash, on the other hand, is the dominant technology for **mass data storage** where high capacity, low cost, and fast sequential transfers are key. Many modern devices, like smartphones, use both: NOR for the initial boot code, and NAND for the operating system and user data.

## 5. Image type
