# OpenWrt<!-- omit in toc -->

- [1. ext4 and squashfs image types](#1-ext4andsquashfsimage-types)
  - [1.1. SquashFS Image](#11-squashfs-image)
    - [1.1.1. How it works in OpenWrt](#111-how-it-works-in-openwrt)
    - [1.1.2. Advantages of SquashFS](#112-advantages-of-squashfs)
    - [1.1.3. Disadvantages of SquashFS](#113-disadvantages-of-squashfs)
  - [1.2. ext4 Image](#12-ext4-image)
    - [How it works in OpenWrt](#how-it-works-in-openwrt)
    - [Advantages of ext4](#advantages-of-ext4)
    - [Disadvantages of ext4](#disadvantages-of-ext4)

## 1. ext4 and squashfs image types

### 1.1. SquashFS Image

> For embedded devices with limited flash memory

SquashFS is a **compressed, read-only filesystem**. It's the default and most common filesystem used for OpenWrt images, especially on embedded devices with limited flash memory (like most routers).

#### 1.1.1. How it works in OpenWrt

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

`ext4` is a journaling filesystem widely used in Linux distributions. In OpenWrt, `ext4` images are typically found for platforms with larger storage, such as x86-based systems (e.g., **mini PCs**, **VMs**) or single-board computers (SBCs) that boot from SD cards or eMMC.

#### How it works in OpenWrt

An `ext4` image usually means the entire root filesystem is a single, writable ext4 partition. There's no separate read-only *base* or *overlay*.

#### Advantages of ext4

- **Full Writable Space**: The entire partition space allocated to `ext4` is available for installation of packages, logs, and user data. This is a significant advantage for devices with large storage, as you can easily utilize the full capacity of an SD card or SSD.
- **Simpler Management**: Since it's a single, writable filesystem, operations like resizing the root partition to fill the entire disk are generally simpler and more straightforward than with *SquashFS* + *OverlayFS*.
- **Better for Data-Intensive Applications**: If you plan to run applications that generate a lot of logs, store large files (e.g., Docker containers, file sharing services), or install many packages, `ext4` is usually a better choice due to its direct access to all available storage.
- **No "Wasted" Space from Modifications**: Files are modified in place, so there's no duplication of files as seen with the OverlayFS model.

#### Disadvantages of ext4

- **No Built-in "Factory Reset" via File System**: Unlike SquashFS, there's no inherent "factory reset" mechanism by simply erasing an overlay. If you corrupt your `ext4` filesystem or configuration, a full reflash of the image is usually required to restore the system to a clean state. You'd need to manually backup/restore configurations.
- **Larger Image Size**: `ext4` images are uncompressed, making them larger than equivalent SquashFS images. This isn't an issue for x86 or SBCs with ample storage but makes them unsuitable for routers with tiny flash memory.
- **Less Robust Against Corruption (Compared to Read-Only)**: While `ext4` is a robust journaling filesystem, a power loss or system crash during a write operation could potentially lead to filesystem corruption, requiring manual recovery tools (`fsck`). The read-only nature of SquashFS offers a higher degree of inherent resilience for the core system.
