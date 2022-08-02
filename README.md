# Helpful Utilities

## GPG-Reduce

A streamlined wrapper around the GPG CLI.

Usage: `gpgr <command> <options>`

Supported Commands: 
```
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