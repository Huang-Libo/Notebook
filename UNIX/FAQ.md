# FAQ for *NIX

## How to display $PATH as one directory per line?

> From [ask ubuntu](https://askubuntu.com/a/600019).

**Question**:

By default, the output of `PATH` is separated by colon:

```plaintext
$ echo $PATH
/bin:/usr/bin:/usr/local/bin
```

The above display style is hard for human to read, it will be better if directories in `PATH` is displayed in single lines:

```plaintext
/bin
/usr/bin
/usr/local/bin
```

**Solution**:

You can do this with any one of the following commands, which substitutes all occurrences of `:` with new lines `\n`.

`sed`:

```sh
sed 's/:/\n/g' <<< "$PATH"
```

`tr`:

```sh
tr ':' '\n' <<< "$PATH"
```

`python`:

```sh
python -c "print(r'$PATH'.replace(':', '\n'))"
```

**Add function to ~/.zshrc**:

```sh
function mypath() { tr ':' '\n' <<< "$PATH" }
```

Then you can use `mypath` to display directories in `PATH` in single lines.
