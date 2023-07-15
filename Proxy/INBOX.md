# INBOX <!-- omit in toc -->

- [1. Clash 怎么配置自定义 Rule](#1-clash-怎么配置自定义-rule)

## 1. Clash 怎么配置自定义 Rule

要配置自定义规则，您需要先了解 Clash 的规则语法。Clash 的规则语法基于 Surge 的规则语法，可以在其官方文档中找到详细的说明。以下是配置自定义规则的基本步骤：

打开 Clash 配置文件（一般为 `config.yaml`）。

在 `rules` 字段下添加自定义规则。例如，假设您要添加一个规则，以匹配所有以 *.example.com* 结尾的域名，您可以按照以下格式编写规则：

`rules`:

- `DOMAIN-SUFFIX,example.com,Proxy`

其中，`DOMAIN-SUFFIX` 表示这是一个域名后缀匹配规则，`example.com` 是要匹配的域名后缀，`Proxy` 是匹配成功后的操作，可以是 `Proxy`、`Direct` 或 `Reject`。

保存配置文件并重新启动 Clash。

注意事项：

Clash 的规则语法非常严格，错误的语法可能会导致 Clash 无法启动或无法正确地匹配流量。

自定义规则的优先级比内置规则低，如果存在冲突，内置规则会优先生效。

如果您要添加多个自定义规则，请确保每个规则之间有一个空行，否则可能会导致规则无法正确解析。
