# OpenWrt<!-- omit in toc -->

- [1. ext4 and squashfs image types](#1-ext4andsquashfsimage-types)
  - [1.1. SquashFS Image](#11-squashfs-image)
    - [1.1.1. How SquashFS works in OpenWrt](#111-how-squashfs-works-in-openwrt)
    - [1.1.2. Advantages of SquashFS](#112-advantages-of-squashfs)
    - [1.1.3. Disadvantages of SquashFS](#113-disadvantages-of-squashfs)
  - [1.2. ext4 Image](#12-ext4-image)

## 1. ext4 and squashfs image types

### 1.1. SquashFS Image

> For embedded devices with limited flash memory

SquashFS is a **compressed, read-only filesystem**. It's the default and most common filesystem used for OpenWrt images, especially on embedded devices with limited flash memory (like most routers).

#### 1.1.1. How SquashFS works in OpenWrt

OpenWrt employs a clever trick to make a read-only SquashFS partition appear writable to the user. It uses an **OverlayFS** (or a similar mechanism like `mini_fo`) to combine the read-only SquashFS root filesystem with a small, writable *JFFS2* (or *UBIFS for NAND flash*) partition.

- `/rom` (**SquashFS**): This is the base, *read-only* part of the filesystem. It contains the core OpenWrt system, pre-installed packages, and default configurations.
- `/overlay` (**JFFS2**/**UBIFS**): This is a small, *writable* partition where all changes, new packages, and custom configurations are stored.
- `/` (**OverlayFS**): The user sees a single, merged filesystem at `/` where changes appear to be applied directly. When you modify a file that exists in `/rom`, a copy of that file is placed in `/overlay` and the system uses the modified version.

#### 1.1.2. Advantages of SquashFS

- **Space Efficiency**: Due to compression, **SquashFS** images are significantly smaller than uncompressed filesystems, which is vital for devices with limited flash memory.
- **Resilience and "Factory Reset" Capability**: Because the base system on SquashFS is read-only, it's very robust. If your writable `/overlay` partition gets corrupted or you mess up your configuration, you can easily perform a "factory reset" by simply erasing the `/overlay` partition. This reverts the system to its initial state from the read-only SquashFS, providing a reliable recovery mechanism.
- **Speed**: Reading from a compressed filesystem can sometimes be faster, especially if the decompression is optimized and the underlying storage is slow.

#### 1.1.3. Disadvantages of SquashFS

- **Limited Writable Space**: The `/overlay` partition is typically **small**. While sufficient for common configurations and a few extra packages, it can become a limitation if you want to install many large packages or store a lot of data.
- **"Wasted" Space on Modifications**: When a file in the read-only SquashFS is modified, the original file remains in SquashFS, and a modified copy is created in `/overlay`. This means you effectively have two copies of the file, consuming more space in `/overlay` than if the file was directly modified on a fully writable filesystem.
- **Less Flexible Partition Resizing**: While it's possible to expand the root filesystem with SquashFS, it's often more complex than with a pure ext4 setup, as you're dealing with two distinct filesystems (**SquashFS** and **JFFS2**/**UBIFS**) and the **OverlayFS** mechanism.

### 1.2. ext4 Image

> Often for x86 and Devices with Larger Storage
