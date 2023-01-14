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
