# GitHub FAQ

## proxy not work for git protocol

Sometimes, we will set proxy in Terminal to speed up our network between China and US like this:

```console
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
```

But please note that this approach only works for the **HTTP/HTTPS** protocol, it has no effect on the **git** protocol:

❌ proxy won't work with:

```plaintext
git@github.com:Alamofire/Alamofire.git
```

✅ proxy will work with:

```plaintext
https://github.com/Alamofire/Alamofire.git 
```

## BUG: No way to clear the markdown preview image cache

**Workaround**:

```console
$ curl -X PURGE https://camo.githubusercontent.com/4d04abe0044d94fefcf9af2133223....
> {"status": "ok", "id": "216-8675309-1008701"}
```

**Reference**:

- [atom/markdown-preview/issues/207: No way to clear the markdown preview image cache](https://github.com/atom/markdown-preview/issues/207#issuecomment-261716706)
- [GitHub Docs: About anonymized URLs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-anonymized-urls)

## BUG: "raw.githubusercontent.com" does not be updated

Adding `?token=$(date +%s)` to the end of the URL.

- [Referred comment in the Issue](https://github.com/orgs/community/discussions/46758#discussioncomment-6078032)
