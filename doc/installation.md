# Installation

## fluent-package

### RPM/DEB (Linux)

```console
$ sudo fluent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ /opt/fluent/bin/fluent-tailcheck --help
```

### .msi (Windows)

`Fluent Package Command Prompt` with Administrator privilege:

```console
$ fluent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ fluent-tailcheck --help
```

## td-agent v4

### RPM/DEB (Linux)

```console
$ sudo td-agent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ /opt/td-agent/bin/fluent-tailcheck --help
```

### .msi (Windows)

`Td-agent Command Prompt` with Administrator privilege:

```console
$ td-agent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ fluent-tailcheck --help
```

## td-agent v3

### RPM/DEB (Linux)

```console
$ sudo td-agent-gem install fluent-tail_checker --bindir /opt/td-agent/embedded/bin
```

Then, you can use the command as follows.

```console
$ /opt/td-agent/embedded/bin/fluent-tailcheck --help
```

Note: On td-agent v3, you need to specify `--bindir /opt/td-agent/embedded/bin` to install the executable under `/opt/td-agent/embedded/bin`.
Without this, the executable will be installed under `/opt/td-agent/embedded/lib/ruby/gems/2.4.0/bin/`.

### .msi (Windows)

`Td-agent Command Prompt` with Administrator privilege:

```console
$ fluent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ fluent-tailcheck --help
```

## Your Ruby environment

```console
$ gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ fluent-tailcheck --help
```
