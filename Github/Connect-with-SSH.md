# Connect with SSH

- [Connect with SSH](#connect-with-ssh)
  - [About SSH](#about-ssh)
  - [Checking for existing SSH keys](#checking-for-existing-ssh-keys)
  - [Generating a new SSH key and adding it to the ssh-agent](#generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
    - [About SSH key passphrases](#about-ssh-key-passphrases)
    - [Generating a new SSH key](#generating-a-new-ssh-key)
    - [Adding your SSH key to the ssh-agent](#adding-your-ssh-key-to-the-ssh-agent)
  - [Adding a new SSH key to your GitHub account](#adding-a-new-ssh-key-to-your-github-account)
  - [Testing your SSH connection](#testing-your-ssh-connection)
  - [Working with SSH key passphrases](#working-with-ssh-key-passphrases)
    - [About passphrases for SSH keys](#about-passphrases-for-ssh-keys)
    - [Adding or changing a passphrase](#adding-or-changing-a-passphrase)
    - [Saving your passphrase in the keychain](#saving-your-passphrase-in-the-keychain)
  - [Logs](#logs)
    - [Oct 5th, 2022](#oct-5th-2022)

## About SSH

> [SSH](https://en.wikipedia.org/wiki/Secure_Shell): **S**ecure **Sh**ell Protocol.

Using the SSH protocol, you can connect and authenticate to remote servers and services. With SSH keys,

- You can connect to GitHub without supplying your *username* and *personal access token* at each visit.
- You can also use an SSH key to sign commits.

When you connect via SSH, you authenticate using a *private key file* on your local machine.

- When you set up SSH, you will need to *generate a new private SSH key* and *add it to the SSH agent*.
- You must also add the public SSH key to your account on GitHub before you use the key to authenticate or sign commits.

To maintain account security, you can regularly review your SSH keys list and revoke any keys that are invalid or have been compromised. For more information, see "[Reviewing your SSH keys](https://docs.github.com/en/github/authenticating-to-github/reviewing-your-ssh-keys)".

If you *haven't* used your SSH key for **a year**, then GitHub will automatically **delete** your inactive SSH key as a security precaution. For more information, see "[Deleted or missing SSH keys](https://docs.github.com/en/articles/deleted-or-missing-ssh-keys)".

## Checking for existing SSH keys

> **Note**: GitHub improved security by dropping older, insecure key types on *March 15, 2022*.
>
> As of that date,
>
> - *DSA keys (`ssh-dss`)* are no longer supported. You cannot add new DSA keys to your personal account on GitHub.com.
> - *RSA keys (`ssh-rsa`)* with a `valid_after` before *November 2, 2021* may continue to use any signature algorithm. RSA keys generated after that date must use a **SHA-2 signature algorithm**. (Some older clients may need to be upgraded in order to use SHA-2 signatures.)

Enter `ls -al ~/.ssh` to see if existing SSH keys are present.

```bash
$ ls -al ~/.ssh
# Lists the files in your .ssh directory, if they exist
```

Check the directory listing to see if you already have a public SSH key. By default, the filenames of supported public keys for GitHub are one of the following.

- id_rsa.pub
- id_ecdsa.pub
- id_ed25519.pub

## Generating a new SSH key and adding it to the ssh-agent

### About SSH key passphrases

When you generate an SSH key, you can add a *passphrase* to further secure the key.

- Whenever you use the key, you must enter the passphrase.
- If your key has a passphrase and you don't want to enter the passphrase every time you use the key, you can add your key to the SSH agent.

The *SSH agent* manages your SSH keys and remembers your passphrase.

### Generating a new SSH key

1️⃣ Paste the text below, substituting in your GitHub email address. This creates a new SSH key, using the provided email as a label.

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

> **Note**: If you are using a legacy system that doesn't support the *Ed25519 algorithm*, use:
>
> ```bash
> $ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
> ```

2️⃣ When you're prompted to "Enter a file in which to save the key," press Enter. This accepts the default file location.

```console
> Enter a file in which to save the key (/Users/YOU/.ssh/id_ALGORITHM: [Press enter]
```

3️⃣ Type a secure passphrase:

```console
> Enter passphrase (empty for no passphrase): [Type a passphrase]
> Enter same passphrase again: [Type passphrase again]
```

### Adding your SSH key to the ssh-agent

When adding your SSH key to the agent, use the **default** macOS `ssh-add` command, and not an application installed by [macports](https://www.macports.org/), [homebrew](http://brew.sh/), or some other external source.

1️⃣ Start the `ssh-agent` in the background.

```bash
$ eval "$(ssh-agent -s)"
Agent pid 59566
```

2️⃣ If you're using *macOS Sierra 10.12.2* or *later*, you will need to modify your `~/.ssh/config` file to automatically load keys into the ssh-agent and store passphrases in your keychain.

- First, check to see if your `~/.ssh/config` file exists in the default location.

    ```bash
    $ open ~/.ssh/config
    > The file /Users/YOU/.ssh/config does not exist.
    ```

- If the file doesn't exist, create the file.

    ```bash
    $ touch ~/.ssh/config
    ```

- Open your `~/.ssh/config file`, then modify the file to contain the following lines. If your SSH key file has a different name or path than the example code, modify the filename or path to match your current setup.

    > **Note**: If you chose not to add a *passphrase* to your key, you should omit the `UseKeychain` line.

    ```bash
    Host *
      AddKeysToAgent yes
      UseKeychain yes # Optional, delete this line if don't use passphrase
      IdentityFile ~/.ssh/id_ed25519
    ```

3️⃣ Add your SSH private key to the `ssh-agent` and store your passphrase in the keychain. If you created your key with a different name, or if you are adding an existing key that has a different name, replace *id_ed25519* in the command with the name of your private key file.

- *Option 1*: Do not use passphrase in SSH key:

    ```bash
    $ ssh-add ~/.ssh/id_ed25519
    ```

- *Option 2*: Use passphrase and store it in keychain:

    ```bash
    $ ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    ```

> **Note**: The `--apple-use-keychain` option stores the passphrase in your keychain for you when you add an SSH key to the ssh-agent. If you chose not to add a passphrase to your key, run the command without the `--apple-use-keychain` option.

## Adding a new SSH key to your GitHub account

1️⃣ Copy the SSH public key to your clipboard.

```bash
$ pbcopy < ~/.ssh/id_ed25519.pub
```

2️⃣ Add public key in Settings -> **SSH and GPG keys**

## Testing your SSH connection

> After you've set up your SSH key and added it to your account on GitHub.com, you can test your connection.

1️⃣ Enter the following:

```bash
$ ssh -T git@github.com
  # Attempts to ssh to GitHub
```

Use `-v` parameter to print verbose log:

```bash
$ ssh -vT git@github.com
> ...
> debug1: identity file /Users/YOU/.ssh/id_rsa type -1
> debug1: identity file /Users/YOU/.ssh/id_rsa-cert type -1
> debug1: identity file /Users/YOU/.ssh/id_dsa type -1
> debug1: identity file /Users/YOU/.ssh/id_dsa-cert type -1
> ...
```

2️⃣ You may see a warning like this:

```console
> The authenticity of host 'github.com (IP ADDRESS)' can't be established.
> RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
> Are you sure you want to continue connecting (yes/no)?
```

3️⃣ Verify that the fingerprint in the message you see matches [GitHub's public key fingerprint](https://docs.github.com/en/github/authenticating-to-github/githubs-ssh-key-fingerprints). If it does, then type `yes`:

```console
> Hi USERNAME! You've successfully authenticated, but GitHub does not
> provide shell access.
```

4️⃣ Verify that the resulting message contains your username. If you receive a "permission denied" message, see "[Error: Permission denied (publickey)](https://docs.github.com/en/articles/error-permission-denied-publickey)".

> **Note**: If everything is configured properly, but your public key still cannot be verified by GitHub, you should check your DNS server is working correctly. For more Info, see [Logs](#logs).

## Working with SSH key passphrases

> You can secure your SSH keys and configure an authentication agent so that you won't have to reenter your passphrase every time you use your SSH keys.

### About passphrases for SSH keys

With SSH keys, if someone gains access to your computer, the attacker can gain access to every system that uses that key. To add an extra layer of security, you can add a passphrase to your SSH key.

To avoid entering the passphrase every time you connect, you can securely save your passphrase in the SSH agent.

### Adding or changing a passphrase

You can **change** the passphrase for an existing private key *without* regenerating the keypair by typing the following command:

```bash
$ ssh-keygen -p -f ~/.ssh/id_ed25519
> Enter old passphrase: [Type old passphrase]
> Key has comment 'your_email@example.com'
> Enter new passphrase (empty for no passphrase): [Type new passphrase]
> Enter same passphrase again: [Repeat the new passphrase]
> Your identification has been saved with the new passphrase.
```

If your key already has a passphrase, you will be prompted to enter it before you can change to a new passphrase.

### Saving your passphrase in the keychain

On *Mac OS X Leopard* through *Mac OS X El Capitan*, these default private key files are handled automatically:

- .ssh/id_rsa
- .ssh/identity

That's to say, the *first time* you use your key, you will be prompted to enter your passphrase. *If you choose to save the passphrase with your keychain, you won't have to enter it again.*

However, in the systems after *Mac OS X El Capitan*, you need to store your passphrase in the keychain when you add your key to the ssh-agent. For more information, see "[Adding your SSH key to the ssh-agent](https://docs.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)".

## Logs

### Oct 5th, 2022

**网络环境**：湖北联通

**现象**：`git push` 失败（之前一直都是正常的）。

终端错误信息：

```console
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
...
```

其实就是**湖北联通 DNS 劫持了 Github 域名** 💢 ，把 GitHub 域名解析到一些保留 IP 地址，导致 fingerprint 与 `~/.ssh/known_hosts` 里存储的不匹配。

**解决方案**：在系统偏好->网络设置里，把默认 DNS 更换成 114DNS（114.114.114.114），就恢复正常了。
