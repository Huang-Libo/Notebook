# Connect with SSH

- [Connect with SSH](#connect-with-ssh)
  - [About SSH](#about-ssh)
  - [Checking for existing SSH keys](#checking-for-existing-ssh-keys)
  - [Generating a new SSH key and adding it to the ssh-agent](#generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
    - [About SSH key passphrases](#about-ssh-key-passphrases)
    - [Generating a new SSH key](#generating-a-new-ssh-key)
    - [Adding your SSH key to the ssh-agent](#adding-your-ssh-key-to-the-ssh-agent)
  - [Adding a new SSH key to your GitHub account](#adding-a-new-ssh-key-to-your-github-account)

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



