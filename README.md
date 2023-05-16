# Crono Scripts

A collection of helpful Bash scripts that automate common tasks and streamline complex processes.

## Batman

Write automated tests for your Bash scripts!

**Help**: `batman -h`

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

**Help**: `cpak h`

**Example**:

```
$ echo "hello" > test1.txt
$ echo "world" > test2.txt
$ cpak p -t 7z -o test-package1 test1.txt
Begin @ 05/15/23 09:10 PM

pack_type=7z
[7z] Packing (file) test1.txt

Files Processed: 1
Duration: 0s

Done @ 05/15/23 09:10 PM
$ cpak p -t 7z -o test-package2 test2.txt
Begin @ 05/15/23 09:10 PM

pack_type=7z
[7z] Packing (file) test2.txt

Files Processed: 1
Duration: 0s

Done @ 05/15/23 09:10 PM
$ cpak u -o test-packages *.7z
Begin @ 05/15/23 09:11 PM

test-package1.7z --> 7z
pack_type=7z
[7z] Unpacking (file) test-package1.7z
pack_type=7z
[7z] Unpacking (file) test-package2.7z

Files Processed: 2
Duration: 0s

Done @ 05/15/23 09:11 PM
$ ls test-packages/
test-package1.7z  test-package2.7z  test1.txt  test2.txt
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