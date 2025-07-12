# PVE<!-- omit in toc -->

- [1. 安装 PVE](#1-安装-pve)
- [2. 常用虚拟机系统](#2-常用虚拟机系统)
  - [2.1. OpenWrt](#21-openwrt)
    - [不同镜像的选择：ext4 / squashfs](#不同镜像的选择ext4--squashfs)
  - [2.2. iStoreOS](#22-istoreos)
  - [2.3. ImmortalWrt](#23-immortalwrt)
    - [Mirrors](#mirrors)
  - [2.4. Ubuntu server](#24-ubuntu-server)
  - [2.5. RouterOS](#25-routeros)
- [3. 小工具](#3-小工具)
- [4. 其他新插件](#4-其他新插件)
- [5. FAQ](#5-faq)
  - [5.1. 新版 OpenWrt 找不到依赖包的问题](#51-新版-openwrt-找不到依赖包的问题)
- [6. Reference](#6-reference)

[Overview of Proxmox Virtual Environment](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview)

Download

[Proxmox VE 8.4 ISO Installer](https://www.proxmox.com/en/downloads)

PVE 是基于 Debian 开发的虚拟机监视器，类似于 VMWare ESXi，但 PVE 是开源的。安装 PVE 类似于裸机安装 Debian 系统，需要制作一个 USD 启动盘。

## 1. 安装 PVE

管理后台

[https://192.168.xx.xx:8006/](https://192.168.xx.xx:8006/)

## 2. 常用虚拟机系统

### 2.1. OpenWrt

[OpenWrt](https://openwrt.org/)

[OpenWrt Packages x86_64](https://openwrt.pkgs.org/24.10/openwrt-packages-x86_64/)

请注意，原版的 OpenWrt 分区容量非常小，只有数百兆，即使 PVE 给其分配很大的硬盘容量，它也只是使用镜像指定的固定容量，剩下的硬盘空间则变成了“未使用容量”。

如果需要在 OpenWrt 中安装第三方插件，最好先给镜像扩容。此规则同意适用于其他衍生版，不过常用的衍生版已经修改过原始镜像设置的大小，可以安装更多的插件，如有需求可以再次扩容。

[OpenWrt / Documentation / User guide / Advanced configuration / Expanding root partition and filesystem (x86)](https://openwrt.org/docs/guide-user/advanced/expand_root)

#### 不同镜像的选择：ext4 / squashfs

SquashFS is a **compressed, read-only filesystem**. It's the default and most common filesystem used for OpenWrt images, especially on *embedded devices* with limited flash memory (like most routers).

ext4 is a journaling filesystem widely used in Linux distributions. In OpenWrt, ext4 images are typically found for platforms with larger storage, such as x86-based systems (e.g., mini PCs, VMs) or single-board computers (SBCs) that boot from SD cards or eMMC.

### 2.2. iStoreOS

[iStore插件包](https://github.com/AUK9527/Are-u-ok)

### 2.3. ImmortalWrt

> An open source OpenWrt variant for mainland China users.

[GitHub: ImmortalWrt](https://github.com/immortalwrt/immortalwrt)

[ImmortalWrt Firmware Selector](https://firmware-selector.immortalwrt.org/)

[ImmortalWrt Downloads](https://downloads.immortalwrt.org/)

#### Mirrors

[MirrorZ](https://help.mirrors.cernet.edu.cn/immortalwrt/)
(中国教育和科研计算机网网络中心)

[Mirror of ImmortalWrt packages](https://mirror.nju.edu.cn/immortalwrt/releases/24.10.1/targets/x86/64/packages/)

### 2.4. Ubuntu server

注意：登录使用的默认用户名不是 root ，而是安装系统设置的用户名。

Ubuntu 设置静态 IP

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

## 3. 小工具

[GitHub 文件加速代理](https://gh-proxy.com/)
[IP Subnet Calculator](https://www.omnicalculator.com/other/ip-subnet)

## 4. 其他新插件

[OpenWrt-nikki](https://github.com/nikkinikki-org/OpenWrt-nikki)

## 5. FAQ

### 5.1. 新版 OpenWrt 找不到依赖包的问题

> 事实上，在 OpenWrt 的软件包网站，是可以找到对应的软件包下载的，但是由于软件库组织的问题，还不能在包管理工具中直接安装对应的软件包。于是只有手动安装这些软件包，当然在安装时还会遇到依赖问题，还要安装对应的依赖。

[OpenWrt 24.10固件安装 Passwall](https://www.rultr.com/tutorials/68871.html)

## 6. Reference

- [在 PVE 虚拟环境中安装 OpenWRT 流程](https://optimus-xs.github.io/posts/install-openwrt-in-pve/)
