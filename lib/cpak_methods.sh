#!/usr/bin/env bash

#TODO: If in sequential mode, decompressions should always multi-thread when available

__decode_filename() {
    local encoded_file="$1"
    echo "${encoded_file//$CSCRIPT_SPACE_ENCODE/\ }"
}

__log_compress_msg() {
    local pack_type="$1"
    local output="$2"

    fancy_print -n -s bold "[$pack_type] "
    fancy_print -n -s bold -c "yellow" "Compressing "

    if [[ "$output" != "" ]]; then
        local file_type="file"
        [ -d "$output" ] && file_type="dir"

        fancy_print -n -s bold "($file_type) "
        echo "$output"
    fi
}

__pack_with_cd() {
    local file="$1"
    local cmd="$2"
    local file="$(__decode_filename $1)"

    local new_file=$(basename "$file")
    local new_dir=$(dirname "$file")

    cmd=$(CS_VAR_SET "file" "\"$new_file\"" "$cmd")
    pushd . && cd "$new_dir" && eval "$cmd" && popd
}

__unpack_with_move() {
    local file="$1"
    local output="$2"
    local cmd="$3"
    local new_location="."

    if [ "$output" != "" ] && [ -d "$output" ]; then
        mv "$file" "$output"
        new_location="$output"
    fi

    pushd . && cd $new_location && eval "$cmd" && popd
}

# 7z
7z_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __pack_with_cd "$file" "7z a -y \"$output.7z\" $(CS_VAR file)"
}

7z_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "7z x -y \"$file\""
}

# zip
zip_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __pack_with_cd "$file" "7z a -y -tzip \"$output.zip\" $(CS_VAR file)"
}

zip_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "7z x -tzip -y \"$file\""
}

# bzip2
bzip_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __pack_with_cd "$file" "pbzip2 -zkc $(CS_VAR file) > \"$output.bz2\""
}

bzip_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "bzip2 -dk \"$file\""
}

# gzip
gzip_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __pack_with_cd "$file" "pigz -kc $(CS_VAR file) > \"$output.gz\""
}

gzip_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "gzip -dk \"$file\""
}

# tar
tar_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    if [ -f "$output.tar" ]; then
        __pack_with_cd "$file" "tar rf \"$output.tar\" $(CS_VAR file)"
    else
        __pack_with_cd "$file" "tar cf \"$output.tar\" $(CS_VAR file)"
    fi
}

tar_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "tar xf \"$file\""
}

# tar.bz2
tar.bz2_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    if [ -f "$output.tar" ]; then
        __pack_with_cd "$file" "tar rf \"$output.tar\" $(CS_VAR file)"
    else
        __pack_with_cd "$file" "tar cf \"$output.tar\" $(CS_VAR file)"
    fi
}

tar.bz2_pack_post() {
    local output="$(__decode_filename $1)"
    __log_compress_msg "tar.bz2"
    __pack_with_cd "$output.tar" "pbzip2 -zf $(CS_VAR file)"
}

tar.bz2_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "tar xf \"$file\""
}

# tar.gz
tar.gz_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    if [ -f "$output.tar" ]; then
        __pack_with_cd "$file" "tar rf \"$output.tar\" $(CS_VAR file)"
    else
        __pack_with_cd "$file" "tar cf \"$output.tar\" $(CS_VAR file)"
    fi
}

tar.gz_pack_post() {
    local output="$(__decode_filename $1)"
    __log_compress_msg "tar.gz"
    __pack_with_cd "$output.tar" "pigz $(CS_VAR file)"
}

tar.gz_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "tar xf \"$file\""
}

# XZ
xz_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __pack_with_cd "$file" "xz -kc -T0 $(CS_VAR file) > \"$output.xz\""
}

xz_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "xz -dk \"$file\""
}

# tar.xz
tar.xz_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    if [ -f "$output.tar" ]; then
        __pack_with_cd "$file" "tar rf \"$output.tar\" $(CS_VAR file)"
    else
        __pack_with_cd "$file" "tar cf \"$output.tar\" $(CS_VAR file)"
    fi
}

tar.xz_pack_post() {
    local output="$(__decode_filename $1)"
    __log_compress_msg "tar.xz"
    __pack_with_cd "$output.tar" "xz -T0 $(CS_VAR file)"
}

tar.xz_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "tar xf \"$file\""
}

# rar
rar_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __pack_with_cd "$file" "rar a -y \"$output.rar\" $(CS_VAR file)"
}

rar_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "unrar x -y \"$file\""
}
