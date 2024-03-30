# FAQ <!-- omit in toc -->

- [1. How To set the PATH for Java on macOS?](#1-how-to-set-the-path-for-java-on-macos)
- [2. Why the output of `/usr/libexec/java_home` is not equal to `$JAVA_HOME`?](#2-why-the-output-of-usrlibexecjava_home-is-not-equal-to-java_home)

## 1. How To set the PATH for Java on macOS?

1. Determine the Java Installation Directory:

    Open directory `/Library/Java/JavaVirtualMachines` and check which Java installation you prefer.

2. Set the `PATH` Environment Variable:

    Once you have determined the Java installation directory, you need to add it to your `PATH` environment variable. You can do this by editing your shell configuration file `.zshrc`.

3. Add Java to `PATH`:

    Add the following line to the file, replacing `<java_home>` with the path to your Java installation directory:

    ```bash
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/<java_home>/Contents/Home"
    export PATH="$PATH:$JAVA_HOME/bin"
    ```

4. Save & apply the Changes:

    ```bash
    source ~/.zshrc
    ```

5. Verify the Configuration:

    To verify that Java is added to your `PATH`, you can execute the following command in Terminal:

    ```bash
    java -version
    ```

    This command should display the version of Java installed on your system.

That's it! You have successfully set the `PATH` for Java on macOS. Now you can use `java` commands from any directory in Terminal.

## 2. Why the output of `/usr/libexec/java_home` is not equal to `$JAVA_HOME`?

1. `/usr/libexec/java_home`: This path typically refers to a utility in macOS systems that helps to locate the preferred Java Home directory. When executed, it returns the path to the preferred Java Home directory on the system. It is a command-line tool provided by macOS for managing Java versions and installations.
2. `$JAVA_HOME`: This is an environment variable that points to the root directory of the *Java Development Kit (JDK)* or *Java Runtime Environment (JRE)* installation. It is commonly used by Java applications or development tools to locate the Java installation directory. Users can set this environment variable to point to the desired Java installation directory based on their requirements.

These two entities are not necessarily equal because

- `/usr/libexec/java_home` is a specific command-line utility in macOS
- `$JAVA_HOME` is a *user-configurable environment variable* that can be set to any Java installation directory

Typically, you would use `/usr/libexec/java_home` to dynamically determine the Java Home directory on a macOS system, and `$JAVA_HOME` would be set either manually or through scripts to point to the desired JDK or JRE installation directory. They serve complementary purposes in managing Java installations and versions on macOS systems.
