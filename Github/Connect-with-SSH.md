# GitHub: Connect with SSH

- [GitHub: Connect with SSH](#github-connect-with-ssh)
  - [About SSH](#about-ssh)
  - [Checking for existing SSH keys](#checking-for-existing-ssh-keys)

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


