# Use Ubuntu in PVE <!-- omit in toc -->

- [1. 安装 Docker](#1-安装-docker)
  - [1.1. 推荐通过 APT 安装 `docker.io`](#11-推荐通过-apt-安装-dockerio)
  - [1.2. 其他可选安装方式（根据需求选择）](#12-其他可选安装方式根据需求选择)
  - [1.3. 验证安装成功](#13-验证安装成功)
- [2. 给 Ubuntu 硬盘扩容](#2-给-ubuntu-硬盘扩容)
  - [2.1. 步骤 1：确认磁盘和空闲空间](#21-步骤-1确认磁盘和空闲空间)
  - [2.2. 步骤 2：扩展逻辑卷（LV）](#22-步骤-2扩展逻辑卷lv)
  - [2.3. 步骤 3：扩展文件系统（使空间生效）](#23-步骤-3扩展文件系统使空间生效)
  - [2.4. 步骤 4：验证结果](#24-步骤-4验证结果)

## 1. 安装 Docker

在 Ubuntu 系统中，安装 `docker` 有 3 种主流的方式，以下是最常用、推荐的 **APT 安装 Docker.io** 方案（适配 Ubuntu 官方软件源，稳定性高）：

### 1.1. 推荐通过 APT 安装 `docker.io`

这是 Ubuntu 官方软件源提供的 Docker 包，操作简单且与系统兼容性好：

1. **更新软件源缓存**：

   ```bash
   sudo apt update
   ```

2. **安装 Docker.io**：

   ```bash
   sudo apt install -y docker.io
   ```

3. **启动并设置开机自启**：

   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

4. **验证安装**（查看 Docker 版本）：

   ```bash
   docker --version
   ```

5. **（可选）配置免 sudo 使用 Docker**（避免每次执行 `docker` 都输密码）：

   ```bash
   sudo usermod -aG docker $USER  # 将当前用户加入 docker 组
   ```

   配置后需 **注销并重新登录**，组权限才会生效。

6. **（可选）配置镜像源**：

   用 sudo 权限编辑这个文件（即使当前用户已加入到 docker 组，更改这个文件也需要 sudo 权限）：

   ```bash
   sudo vim /etc/docker/daemon.json
   ```

   ```json
    {
        "registry-mirrors": [
            "https://docker.m.daocloud.io"
        ],
        "debug": true
    }
   ```

   重启服务：

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   ```

   执行 `docker info` 验证配置是否已生效：

   ```console
   ...
   Registry Mirrors:
   https://docker.m.daocloud.io/
   ```

### 1.2. 其他可选安装方式（根据需求选择）

| 安装方式        | 命令                                | 特点                                                        |
|---------------|-------------------------------------|-----------------------------------------------------------|
| Snap 安装       | `sudo snap install docker`          | 安装快速，版本较新（如 28.1.1+1），但 Snap 包可能有沙箱权限限制 |
| Podman 兼容模式 | `sudo apt install -y podman-docker` | 安装 Podman（Docker 替代品）+ 兼容层，适合偏好 Podman 的场景   |

### 1.3. 验证安装成功

无论选择哪种方式，安装后执行以下命令，若能正常显示容器列表（空列表也正常），则说明安装成功：

```bash
sudo docker ps  # 或无 sudo（已配置免 sudo 后）：docker ps
```

## 2. 给 Ubuntu 硬盘扩容

> 问题：PVE 给 Ubuntu 设置的硬盘空间是 32GB ，但安装系统的时候默认只用了一部分，还有 15GB 空闲空间，如何将空闲空间分配给根目录?

先切换到 root 用户，全程使用 root 权限操作：

```bash
sudo -i
```

### 2.1. 步骤 1：确认磁盘和空闲空间

首先检查磁盘分区和 LVM 卷组状态：

```bash
# 查看磁盘分区（确认是否有未分配空间）
fdisk -l /dev/sda
```

```console
Disk /dev/sda: 32 GiB, 34359738368 bytes, 67108864 sectors
Disk model: QEMU HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 28CFED39-6900-42C7-AF9F-0FB617BA8A30

Device       Start      End  Sectors Size Type
/dev/sda1     2048     4095     2048   1M BIOS boot
/dev/sda2     4096  4198399  4194304   2G Linux filesystem
/dev/sda3  4198400 67106815 62908416  30G Linux filesystem
```

---

```bash
# 查看 LVM 卷组（VG）状态（确认是否有空闲空间）
vgdisplay ubuntu-vg
```

```console
  --- Volume group ---
  VG Name               ubuntu-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <30.00 GiB
  PE Size               4.00 MiB
  Total PE              7679
  Alloc PE / Size       3839 / <15.00 GiB
  Free  PE / Size       3840 / 15.00 GiB
  VG UUID               aqbxuz-KZ8J-qfMC-4E3A-QK69-o6Pk-D0heIN
```

从输出的信息可以看出，系统已经识别到了全部 32GB 磁盘空间，并且卷组 `ubuntu-vg` 中已有 15GB 空闲空间`（Free PE / Size: 3840 / 15.00 GiB）`，可以直接将这部分空间分配给根目录。具体步骤如下：

### 2.2. 步骤 2：扩展逻辑卷（LV）

将卷组中所有空闲空间分配给根目录对应的逻辑卷：

```bash
lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
```

```console
  Size of logical volume ubuntu-vg/ubuntu-lv changed from <15.00 GiB (3839 extents) to <30.00 GiB (7679 extents).
  Logical volume ubuntu-vg/ubuntu-lv successfully resized.
```

### 2.3. 步骤 3：扩展文件系统（使空间生效）

Ubuntu Server 默认使用 ext4 文件系统，执行以下命令扩展文件系统：

```bash
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```

```console
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/mapper/ubuntu--vg-ubuntu--lv is mounted on /; on-line resizing required
old_desc_blocks = 2, new_desc_blocks = 4
The filesystem on /dev/mapper/ubuntu--vg-ubuntu--lv is now 7863296 (4k) blocks long.
```

### 2.4. 步骤 4：验证结果

查看根目录空间是否已扩展：

```bash
root@ubuntu-server:~# df -h /
```

执行后，`/` 分区的总容量从原来的 15GB 变为约 30GB（扣除 `/boot` 分区的 2GB 后，接近 32GB 总容量），说明扩展成功。

```console
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   30G  4.7G   24G  17% /
```
