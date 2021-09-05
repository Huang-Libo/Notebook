# React Native：FAQ

## watchman 导致的 RN 项目运行失败

**问题**：执行 `npx react-native run-ios` 运行 RN 项目，终端内提示 `/usr/local/var/run/watchman/` 这个目录不存在。

**分析**：这个目录本应该是 `watchman` 安装时产生的，但使用 `brew` 重新安装 `watchman` 也未能修复这个问题。执行 `watchman version` ，也是提示上述目录不存在。

**相关资料**：根据 watchman 项目中[这个 issue 的回答](https://github.com/facebook/watchman/issues/640#issuecomment-416983649)，可以自行创建相关目录，设置合适的目录权限即可。

**下面介绍解决此问题的详细步骤**：

在 `/usr/local/var` 目录下创建 **run** 目录（如果没有此目录才需执行）：

```console
sudo mkdir run
```

执行 `ll` 查看 **run** 目录的文件权限：

```plaintext
total 0
drwxr-xr-x   4 huanglibo  admin   128B Jan 12  2018 homebrew
drwxr-xr-x   3 huanglibo  admin    96B Oct 27  2017 log
drwxr-xr-x   2 huanglibo  admin    64B Oct 27  2017 mongodb
drwxr-xr-x  59 huanglibo  admin   1.8K May  1  2020 mysql
drwx------  24 huanglibo  admin   768B Jan 12  2018 postgres
drwxr-xr-x   2 root       wheel    64B Aug 28 00:49 run
```

可以看到使用 `sudo` 命令创建的目录默认拥有者是 `root` ，默认组是 `wheel` 。

修改 **run** 目录的 owner ：

```console
sudo chown huanglibo run
```

修改 **run** 目录的 group ：

```console
chgrp admin run
```

执行 `cd run` 后，在 **run** 目录下创建 **watchman** 目录：

```console
mkdir watchman
```

执行 `ll` 查看 **watchman** 目录的权限，是正常的，无需修改：

```console
total 0
drwxr-xr-x  2 huanglibo  admin    64B Aug 28 00:50 watchman
```

再次运行 `watchman version` ，可正常输出版本信息了：

```console
{
    "version": "2021.08.23.00"
}
```

最后，执行 `npx react-native run-ios` ，项目能正常运行了。
