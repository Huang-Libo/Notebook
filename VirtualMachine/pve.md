# PVE<!-- omit in toc -->

- [1. 安装 PVE](#1-安装-pve)
- [2. 常用虚拟机系统](#2-常用虚拟机系统)
  - [2.1. OpenWrt](#21-openwrt)
  - [2.2. iStoreOS](#22-istoreos)
  - [2.3. ImmortalWrt](#23-immortalwrt)
    - [2.3.1. Mirrors](#231-mirrors)
  - [2.4. Ubuntu server](#24-ubuntu-server)
    - [2.4.1. Ubuntu 设置静态 IP](#241-ubuntu-设置静态-ip)
  - [2.5. RouterOS](#25-routeros)
  - [2.6. 其他系统](#26-其他系统)
- [3. 示例：安装原版 OpenWrt 镜像](#3-示例安装原版-openwrt-镜像)
  - [3.1. 镜像选择](#31-镜像选择)
    - [3.1.1. 使用 legacy BIOS 镜像](#311-使用-legacy-bios-镜像)
    - [3.1.2. 使用 firmware-selector 预装软件包](#312-使用-firmware-selector-预装软件包)
  - [3.2. 导入镜像](#32-导入镜像)
  - [3.3. 安装完成后的配置](#33-安装完成后的配置)
- [4. 小工具](#4-小工具)
- [5. 其他新插件](#5-其他新插件)
- [6. FAQ](#6-faq)
  - [6.1. 新版 OpenWrt 找不到依赖包的问题](#61-新版-openwrt-找不到依赖包的问题)
- [7. Reference](#7-reference)

## 1. 安装 PVE

[PVE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) 是基于 Debian 开发的*虚拟机监视器（Hypervisor）*，类似于 *VMWare ESXi* ，但 PVE 是开源的。安装 PVE 类似于裸机安装 Debian 系统，需要制作一个 USD 启动盘。

下载页面：

- [Proxmox VE 8.4 ISO Installer](https://www.proxmox.com/en/downloads)

管理后台：

- [https://192.168.xx.xx:8006/](https://192.168.xx.xx:8006/)

## 2. 常用虚拟机系统

### 2.1. OpenWrt

请注意，原版的 [OpenWrt](https://openwrt.org/) 分区容量非常小，只有数百兆，即使 PVE 给其分配很大的硬盘容量，它也只是使用镜像指定的固定容量，剩下的硬盘空间则变成了“未使用容量”。

如果需要在 OpenWrt 中安装第三方插件，最好先给镜像扩容。此规则同意适用于其他衍生版，不过常用的衍生版已经修改过原始镜像设置的大小，可以安装更多的插件，如有需求可以再次扩容。

[OpenWrt / Documentation / User guide / Advanced configuration / Expanding root partition and filesystem (x86)](https://openwrt.org/docs/guide-user/advanced/expand_root)

### 2.2. iStoreOS

- [iStoreOS: 开源免费的路由➕存储系统](https://site.istoreos.com/)
- [iStore插件包](https://github.com/AUK9527/Are-u-ok)

### 2.3. ImmortalWrt

> An open source OpenWrt variant for mainland China users.

- [GitHub: ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [ImmortalWrt Firmware Selector](https://firmware-selector.immortalwrt.org/)
- [ImmortalWrt Downloads](https://downloads.immortalwrt.org/)

#### 2.3.1. Mirrors

[MirrorZ](https://help.mirrors.cernet.edu.cn/immortalwrt/)
(中国教育和科研计算机网网络中心)

[Mirror of ImmortalWrt packages](https://mirror.nju.edu.cn/immortalwrt/releases/24.10.1/targets/x86/64/packages/)

### 2.4. Ubuntu server

注意：登录使用的默认用户名不是 `root` ，而是安装系统设置的用户名。

#### 2.4.1. Ubuntu 设置静态 IP

[Setting a Static IP in Ubuntu – Linux IP Address Tutorial](https://www.freecodecamp.org/news/setting-a-static-ip-in-ubuntu-linux-ip-address-tutorial/)

在 Ubuntu Server 24.04.2 中设置静态 IP 需要通过 Netplan 配置工具完成

查看当前网络接口，找到需要配置的网卡名称（如 `eth0`、`ens18` 等）：

```bash
ip addr show
```

在 `/etc/netplan` 目录下添加配置文件，文件名可以使用 `01-xxx.yaml` ：

> Netplan is the default network management tool for the latest Ubuntu versions.

```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: no
      addresses: [192.168.50.11/24]
      routes:
        - to: default
          via: 192.168.50.4
      nameservers:
        addresses: [223.5.5.5, 114.114.114.114, 8.8.8.8, 1.1.1.1]
```

应用配置

```bash
sudo netplan try
sudo netplan apply
```

### 2.5. RouterOS

[RouterOS](https://mikrotik.com/download)

适合做主路由。

### 2.6. 其他系统

- [Arch Linux](https://archlinux.org/)
- [Manjaro](https://manjaro.org/)

## 3. 示例：安装原版 OpenWrt 镜像

### 3.1. 镜像选择

#### 3.1.1. 使用 legacy BIOS 镜像

> Proxmox Virtual Environment (PVE) uses **SeaBIOS (legacy BIOS)** as the default firmware for its virtual machines.

由于 PVE 默认使用 **SeaBIOS** ，对于 x86_64 设备，最好选择

- generic-ext4-combined.img.gz

而非

- generic-ext4-combined-**efi**.img.gz

在 PVE 中使用 UEFI 需要额外的配置，所以无特殊需求的话并不推荐。

> UEFI VMs in Proxmox (using OVMF) require an additional 128KB virtual disk for persistent variables (the EFI vars store). While small, it's an extra configuration step that isn't needed with SeaBIOS. If this disk isn't properly handled or gets corrupted, it can lead to boot issues.

#### 3.1.2. 使用 firmware-selector 预装软件包

在 [firmware-selector](https://firmware-selector.openwrt.org/) 页面可以选择预装软件包并配置初次启动时需要运行的脚本。

由于原版的 OpenWrt 镜像默认容量很小，一般都需要扩容，在 [Expanding root partition and filesystem](https://openwrt.org/docs/guide-user/advanced/expand_root?s[]=resize) 页面可以找到相关教程。

使用 [firmware-selector](https://firmware-selector.openwrt.org/) 可以将扩容所需的软件包预安装在固件中，在默认的软件包列表中添加：

```plaintext
parted losetup resize2fs blkid openssh-sftp-server
```

> openssh-sftp-server 是为了方便使用 scp 传文件。

之后安装并配置好系统之后，再根据上述扩容文档的步骤来执行扩容。扩容完成后可以使用 `df -h` 查看是否成功：

```bash
root@OpenWrt:~# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root                 2.1G     27.0M      2.0G   1% /
tmpfs                   995.8M    228.0K    995.6M   0% /tmp
/dev/sda1                15.7M      5.7M      9.7M  37% /boot
/dev/sda1                15.7M      5.7M      9.7M  37% /boot
tmpfs                   512.0K         0    512.0K   0% /dev
```

### 3.2. 导入镜像

以 openwrt-24.10.2 镜像为例，这是一个后缀为 `.img.gz` 的镜像，使用 `gunzip` 解压：

```bash
gunzip openwrt-24.10.2-28ccda1a7afa-x86-64-generic-ext4-combined.img.gz
```

在 pve 中选择 *local (pve) - ISO Images* ，上传成功之后，会弹出一个页面并给出目标地址，记录下这个地址，下一步在导入镜像到虚拟机的命令中需要使用，比如：

target file:

```plaintext
/var/lib/vz/template/iso/openwrt-24.10.2-28ccda1a7afa-x86-64-generic-ext4-combined.img
```

先创建一个新的虚拟机，相关配置：

| key  | value             | comment          |
|------|-------------------|------------------|
| BIOS | Default (SeaBIOS) | 比 UEFI 配置简单 |
| CPU  | x86-64-v2-AES     | 性能比 kvm64 好  |

ssh 到 **pve terminal** 导入镜像：

命令的格式：

```bash
qm importdisk <VMID> <source-file> <target-storage> [OPTIONS]
```

比如：

```bash
qm importdisk 105 /var/lib/vz/template/iso/openwrt-24.10.2-28ccda1a7afa-x86-64-generic-ext4-combined.img local-lvm
```

输出：

```console
importing disk '/var/lib/vz/template/iso/openwrt-24.10.2-28ccda1a7afa-x86-64-generic-ext4-combined.img' to VM 105
...
unused0: successfully imported disk 'local-lvm:vm-105-disk-1'
```

其中 *local-lvm:vm-105-disk-1* 就是新创建的 Disk 。

在新创建的虚拟机中，删除多余的硬件，选中刚创建的 Disk ，将其设置为 SATA 硬盘并 Attach 。如果需要重新配置硬盘大小，在 *Disk Action - Resize* 中配置。注意，刚配置好的硬盘需要修改启动顺序，在 *Options - Boot Order* 中修改。

### 3.3. 安装完成后的配置

查看分区信息：

```bash
df -h
```

修改默认的 ip 地址，在 `/etc/config/network` 中修改 `ipaddr` & `netmask` ， 修改完成并保存后执行 `service network restart` 。

`/etc/config/network` sample:

```plaintext
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd2b:9cd5:7f1::/48'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.50.5'
        option netmask '255.255.255.0'
        option ip6assign '60'
```

之后就方便使用 ssh 登录了。

最后，通过浏览器登录 OpenWrt 后台，配置 Gateway / DNS / DHCP 等参数，以便让其连上网络。

如果是当旁路由使用，则将 DHCP 关闭，将 Gateway 和 DNS 的值都设置为主路由的 IP 地址。

## 4. 小工具

[GitHub 文件加速代理](https://gh-proxy.com/)
[IP Subnet Calculator](https://www.omnicalculator.com/other/ip-subnet)

## 5. 其他新插件

[OpenWrt-nikki](https://github.com/nikkinikki-org/OpenWrt-nikki)

## 6. FAQ

### 6.1. 新版 OpenWrt 找不到依赖包的问题

> 事实上，在 OpenWrt 的软件包网站，是可以找到对应的软件包下载的，但是由于软件库组织的问题，还不能在包管理工具中直接安装对应的软件包。于是只有手动安装这些软件包，当然在安装时还会遇到依赖问题，还要安装对应的依赖。

[OpenWrt 24.10固件安装 Passwall](https://www.rultr.com/tutorials/68871.html)

## 7. Reference

- [在 PVE 虚拟环境中安装 OpenWRT 流程](https://optimus-xs.github.io/posts/install-openwrt-in-pve/)
