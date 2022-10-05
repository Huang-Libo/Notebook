# GitHub: Connect with SSH

- [GitHub: Connect with SSH](#github-connect-with-ssh)
  - [About SSH](#about-ssh)

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
