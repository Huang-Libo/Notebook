# git FAQ

## git 默认不区分大小写

如果只改变*文件名*或*目录名*的大小写，git 的默认策略是会忽略的。

让 git 区分大小写：

```console
git config core.ignorecase false
```
