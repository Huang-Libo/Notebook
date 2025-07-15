# OpenWrt<!-- omit in toc -->

- [1. Instruction of OpenWrt](#1-instruction-of-openwrt)
- [2. ext4 and SquashFS image types](#2-ext4-and-squashfs-image-types)
  - [2.1. SquashFS Image](#21-squashfs-image)
    - [2.1.1. How it works in OpenWrt](#211-how-it-works-in-openwrt)
    - [2.1.2. Advantages of SquashFS](#212-advantages-of-squashfs)
    - [2.1.3. Disadvantages of SquashFS](#213-disadvantages-of-squashfs)
  - [2.2. ext4 Image](#22-ext4-image)
    - [2.2.1. How it works in OpenWrt](#221-how-it-works-in-openwrt)
    - [2.2.2. Advantages of ext4](#222-advantages-of-ext4)
    - [2.2.3. Disadvantages of ext4](#223-disadvantages-of-ext4)
  - [2.3. Summary](#23-summary)
  - [2.4. Terminology](#24-terminology)
    - [2.4.1. JFFS2 / UBIFS](#241-jffs2--ubifs)
    - [2.4.2. NOR / NAND flash](#242-nor--nand-flash)
- [3. Image type](#3-image-type)

## 1. Instruction of OpenWrt

OpenWrt: **Wrt** stands for **W**ireless **r**ou**t**er.

## 2. ext4 and SquashFS image types

### 2.1. SquashFS Image

> For embedded devices with limited flash memory

SquashFS is a **compressed, read-only filesystem**. It's the default and most common filesystem used for OpenWrt images, especially on embedded devices with limited flash memory (like most routers).

#### 2.1.1. How it works in OpenWrt

OpenWrt employs a clever trick to make a read-only SquashFS partition appear writable to the user. It uses an **OverlayFS** (or a similar mechanism like `mini_fo`) to combine the read-only SquashFS root filesystem with a small, writable *JFFS2* (or *UBIFS for NAND flash*) partition.

- `/rom` (**SquashFS**): This is the base, *read-only* part of the filesystem. It contains the core OpenWrt system, pre-installed packages, and default configurations.
- `/overlay` (**JFFS2**/**UBIFS**): This is a small, *writable* partition where all changes, new packages, and custom configurations are stored.
- `/` (**OverlayFS**): The user sees a single, merged filesystem at `/` where changes appear to be applied directly. When you modify a file that exists in `/rom`, a copy of that file is placed in `/overlay` and the system uses the modified version.

#### 2.1.2. Advantages of SquashFS

- **Space Efficiency**: Due to compression, **SquashFS** images are significantly smaller than uncompressed filesystems, which is vital for devices with limited flash memory.
- **Resilience and "Factory Reset" Capability**: Because the base system on SquashFS is read-only, it's very robust. If your writable `/overlay` partition gets corrupted or you mess up your configuration, you can easily perform a "factory reset" by simply erasing the `/overlay` partition. This reverts the system to its initial state from the read-only SquashFS, providing a reliable recovery mechanism.
- **Speed**: Reading from a compressed filesystem can sometimes be faster, especially if the decompression is optimized and the underlying storage is slow.

#### 2.1.3. Disadvantages of SquashFS

- **Limited Writable Space**: The `/overlay` partition is typically **small**. While sufficient for common configurations and a few extra packages, it can become a limitation if you want to install many large packages or store a lot of data.
- **"Wasted" Space on Modifications**: When a file in the read-only SquashFS is modified, the original file remains in SquashFS, and a modified copy is created in `/overlay`. This means you effectively have two copies of the file, consuming more space in `/overlay` than if the file was directly modified on a fully writable filesystem.
- **Less Flexible Partition Resizing**: While it's possible to expand the root filesystem with SquashFS, it's often more complex than with a pure ext4 setup, as you're dealing with two distinct filesystems (**SquashFS** and **JFFS2**/**UBIFS**) and the **OverlayFS** mechanism.

### 2.2. ext4 Image

> Often for x86 and Devices with Larger Storage

`ext4` is a journaling filesystem widely used in Linux distributions. In OpenWrt, `ext4` images are typically found for platforms with larger storage, such as x86-based systems (e.g., **mini PCs**, **VMs**) or single-board computers (SBCs) that boot from SD cards or eMMC.

#### 2.2.1. How it works in OpenWrt

An `ext4` image usually means the entire root filesystem is a single, writable ext4 partition. There's no separate read-only *base* or *overlay*.

#### 2.2.2. Advantages of ext4

- **Full Writable Space**: The entire partition space allocated to `ext4` is available for installation of packages, logs, and user data. This is a significant advantage for devices with large storage, as you can easily utilize the full capacity of an SD card or SSD.
- **Simpler Management**: Since it's a single, writable filesystem, operations like resizing the root partition to fill the entire disk are generally simpler and more straightforward than with *SquashFS* + *OverlayFS*.
- **Better for Data-Intensive Applications**: If you plan to run applications that generate a lot of logs, store large files (e.g., Docker containers, file sharing services), or install many packages, `ext4` is usually a better choice due to its direct access to all available storage.
- **No "Wasted" Space from Modifications**: Files are modified in place, so there's no duplication of files as seen with the OverlayFS model.

#### 2.2.3. Disadvantages of ext4

- **No Built-in "Factory Reset" via File System**: Unlike SquashFS, there's no inherent "factory reset" mechanism by simply erasing an overlay. If you corrupt your `ext4` filesystem or configuration, a full reflash of the image is usually required to restore the system to a clean state. You'd need to manually backup/restore configurations.
- **Larger Image Size**: `ext4` images are uncompressed, making them larger than equivalent SquashFS images. This isn't an issue for x86 or SBCs with ample storage but makes them unsuitable for routers with tiny flash memory.
- **Less Robust Against Corruption (Compared to Read-Only)**: While `ext4` is a robust journaling filesystem, a power loss or system crash during a write operation could potentially lead to filesystem corruption, requiring manual recovery tools (`fsck`). The read-only nature of SquashFS offers a higher degree of inherent resilience for the core system.

### 2.3. Summary

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

### 2.4. Terminology

#### 2.4.1. JFFS2 / UBIFS

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

#### 2.4.2. NOR / NAND flash

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

## 3. Image type
