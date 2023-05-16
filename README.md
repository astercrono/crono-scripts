# Crono Scripts

A collection of helpful Bash scripts that automate common tasks and streamline complex processes.

## Batman

Write automated tests for your Bash scripts!

```
$ batman -hp
Usage: batman [options] TARGETS

Options:
    -p
        Enable plaintext mode.
        Removes all styles and colors from output.
    -h
        Print this help message

TARGETS
May be a single file or GLOB pattern of test scripts.

Test scripts must:
    - End with _test.sh
    - Make at least 1 valid use of run_test() and case_pass()
```

**Example Usage**:

```
$ batman crono-scripts/test/sample*
______  ___ ________  ___  ___   _   _
| ___ \/ _ \_   _|  \/  | / _ \ | \ | |
| |_/ / /_\ \| | | .  . |/ /_\ \|  \| |
| ___ \  _  || | | |\/| ||  _  || . ` |
| |_/ / | | || | | |  | || | | || |\  |
\____/\_| |_/\_/ \_|  |_/\_| |_/\_| \_/

__________________________________________________
> crono-scripts/test/sample_test.sh

Running: The Foo Test
    [PASS] Check 1
    [FAIL] Check 2                         -- Failed because BAD. Very bad!
    [PASS] Check 3

Running: The Bar Test
    [PASS] Check 1
    [PASS] Check 2

Total Tests:  2
    Passed:   1
    Failed:   1

Failed Tests:
    The Foo Test

__________________________________________________
> Grand Summary:

Total Suites: 1
    Passed:   0
    Failed:   1

Failed Suites:
        crono-scripts/test/sample test.sh
```

## CPAK

A unified front-end for most of your archival needs with an emphasis on multi-threading.

```
$ cpak h
Usage: cpak COMMAND [options] TARGET(S)

Commands:
    h)  Print this help message
    p)  Pack (archive and compress) files
    u)  Unpack (decompress and unarchive) files

Options:
    -i
        Run in test mode. Inspect the output.
        No real actions are performed.
    -s
        Sequential mode. For unpacking only.
        Disables subjobbing for batch processing
    -o PATH
        Packing: Output file basename when packing.
        Unpacking: Directory to unpack into
    -t TYPE
        Specify pion type.
        Use all applicable files within the directory.
    -v
        Run in verbose mode

Supported Types:
    7z              7z Compressed Archive
    bz2             BZip2 Compression (Single File)
    gz              GZip Compression (Single File)
    rar             Rar Compressed Archive
    tar             Tarball Archive
    tar.bz2         BZip2 Compressed Tarball
    tar.gz          GZip Compressed Tarball
    tar.xz          XZ Compressed Tarball
    xz              XZ Compression (Single File)
    zip             Zip Compressed Archive
```

There are a variety of requirements for CPAK, most of which depend on the chosen packaging method.

**General Requirements**:

- `bc`

**Per Method Requirements:**

- *7Zip*: `7z`
- *Zip*: `7z`
- *BZip*: `bzip2` + `pbzip2`
- *GZip*: `gzip` + `pigz`
- *Tar*: `tar`
- *XZ*: `xz`
- *RAR*: `rar` + `unrar`

**Notes**:

- Examples of using Batman can be found under `crono-scripts/test`. 
    - `crono-scripts/test/sample_test.sh` is a good place to start.
- When batch extracting archives, each archive is unpacked in a sub-job.
- When batch packing, the packing process is sequential. It does not sub-job.
    - However, the individual steps will utilize multi-threading if the underlying
      method / algorithm supports. 

## GPG-Reduce

A simplified wrapper around the GPG CLI.

```
$ gpgr help
Usage: gpgr <command> <options>
Supported Commands:
    new                                 -- Create a new key pair
    encrypt      <filename>             -- Encrypt file to send
    decrypt      <filename> <output>    -- Decrypt file from trusted sender with optional output file
    import       <filename>             -- Import a trusted user's public key
    export       <name>                 -- Export public key of user
    fingerprint  <name>                 -- Show fingerprint for user
    list                                -- List all stored public keys
    list-secret                         -- List all stored secret keys
    sign         <filename>             -- Signs the given file
    clearsign    <filename>             -- Signs the given file in clear text
    verify       <filename>             -- Verifies the signature of the given file
    protect      <filename>             -- Password protects and signs a file
    open         <filename> <output>    -- Open a protected file
```

## RTree

Read file paths from STDIN and print them out in plaintex, tabulated tree.

**Example**:

```
$ find . -not -path '*/\.*' | rtree
./
    batman
    README.md
    test/
        cpak_test.sh
        sample_test.sh
    cpak
    lib/
        cpak_util.sh
        batman_banner.txt
        cpak_methods.sh
        batlib.sh
        fancy.sh
        configure.sh
    gpgr
    rtree
    LICENSE
```

**Notes**: 
- RTree requires Ruby to be installed.
- A more efficient version that is written in Go exists at [crono-tools](https://github.com/astercrono/crono-tools). RTree is sufficient for "most" use cases, but if you notice performance issues, give [crono-tools](https://github.com/astercrono/crono-tools) a try.