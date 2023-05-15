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

    new_file=$(basename "$file")
    new_dir=$(dirname "$file")

    cmd=$(CS_VAR_SET "file" "\"$new_file\"" "$cmd")
    echo "cmd=$cmd"
    pushd . && cd "$new_dir" && eval "$cmd" && popd
}

# TODO: Handle package name not matching unpack (original file) name
# MOVE THEN UNPACK  -  THAT IS THE SOLUTION
__unpack_with_move() {
    local file="$1"
    local output="$2"
    local cmd="$3"

    local new_location="."
    echo "output=$output"
    if [ "$output" != "" ] && [ -d "$output" ]; then
        mv "$file" "$output"
        new_location="$output"
    #    echo "$output"
    # else
    #$     echo "."
    fi

    pushd . && cd $new_location && eval "$cmd" && popd
}

# 7z
7z_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    # 7z a -y "$output.7z" "$file"
    __pack_with_cd "$file" "7z a -y \"$output.7z\" $(CS_VAR file)"
}

7z_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "7z x -y \"$file\""

    # new_location=$(__handle_move "$file" "$output")
    # echo "new_location=$new_location"
    # pushd . && cd $new_location && 7z x -y "$file" && popd
}

# zip
zip_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    # 7z a -y -tzip "$output.zip" "$file"
    __pack_with_cd "$file" "7z a -y -tzip \"$output.zip\" $(CS_VAR file)"
}

zip_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __unpack_with_move "$file" "$output" "7z x -tzip -y \"$file\""

    # __handle_move "$file" "$output"
    # 7z x -y -tzip "$file"
}

# bzip2
bzip_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __pack_with_cd "$file" "pbzip2 -zkc $(CS_VAR file) > \"$output.bz2\""
    # pbzip2 -zkc "$file" > "$output.bz2"
}

bzip_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "bzip2 -dk \"$file\""

    # bzip2 -dkc "$file"
    # __handle_move "$file" "$output"
}

# gzip
gzip_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __pack_with_cd "$file" "pigz -kc $(CS_VAR file) > \"$output.gz\""
    # pigz -k "$file"
}

gzip_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "gzip -dk \"$file\""

    # gzip -dk "$file"
    # __handle_move "$file" "$output"
}

# tar
tar_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    if [ -f "$output.tar" ]; then
        echo 1
        # tar rf "$output.tar" "$file"
        # tar rf "$output.tar" "$file"
    else
        __pack_with_cd "$file" "tar cf \"$output.tar\" $(CS_VAR file)"
        # tar cf "$output.tar" "$file"
    fi
}

tar_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "tar xf \"$file\""
    # tar xf "$file"
    # __handle_move "$file" "$output"
}

# tar.bz2
tar.bz2_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    if [ -f "$output.tar" ]; then
        __pack_with_cd "$file" "tar rf \"$output.tar\" $(CS_VAR file)"
        # tar rf "$output.tar" "$file"
    else
        __pack_with_cd "$file" "tar cf \"$output.tar\" $(CS_VAR file)"
        # tar cf "$output.tar" "$file"
    fi

    # if [ -f "$output.tar" ]; then
    #     tar rf "$output.tar" "$file"
    # else
    #     tar cf "$output.tar" "$file"
    # fi
}

tar.bz2_pack_post() {
    local output="$(__decode_filename $1)"
    __log_compress_msg "tar.bz2"
    __pack_with_cd "$output.tar" "pbzip2 -zf $(CS_VAR file)"
    # pbzip2 -zf "$output.tar"
}

tar.bz2_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "tar xf \"$file\""
    # tar xf "$file"
    # __handle_move "$file" "$output"
}

# tar.gz
tar.gz_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    if [ -f "$output.tar" ]; then
        __pack_with_cd "$file" "tar rf \"$output.tar\" $(CS_VAR file)"
        # tar rf "$output.tar" "$file"
    else
        __pack_with_cd "$file" "tar cf \"$output.tar\" $(CS_VAR file)"
        # tar cf "$output.tar" "$file"
    fi

    # if [ -f "$output.tar" ]; then
    #     tar rf "$output.tar" "$file"
    # else
    #     tar cf "$output.tar" "$file"
    # fi
}

tar.gz_pack_post() {
    local output="$(__decode_filename $1)"
    __log_compress_msg "tar.gz"
    __pack_with_cd "$output.tar" "pigz $(CS_VAR file)"
    # pigz "$output.tar"
}

tar.gz_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "tar xf \"$file\""
    # tar xf "$file"
    # __handle_move "$file" "$output"
}

# XZ
xz_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    # 7z a -y -txz "$output.xz" "$file"
    # xz -k -T0 "$output"
    __pack_with_cd "$file" "xz -kc -T0 $(CS_VAR file) > \"$output.xz\""
}

xz_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "xz -dk \"$file\""

    # xz -dk "$file"
    # __handle_move "$file" "$output"
}

# tar.xz
# how to do pack_with_cd with post commands that do not have file, only output
tar.xz_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    if [ -f "$output.tar" ]; then
        __pack_with_cd "$file" "tar rf \"$output.tar\" $(CS_VAR file)"
        # tar rf "$output.tar" "$file"
    else
        __pack_with_cd "$file" "tar cf \"$output.tar\" $(CS_VAR file)"
        # tar cf "$output.tar" "$file"
    fi
}

tar.xz_pack_post() {
    local output="$(__decode_filename $1)"
    __log_compress_msg "tar.xz"
    __pack_with_cd "$output.tar" "xz -T0 $(CS_VAR file)"
    # xz -T0 "$output.tar"
}

tar.xz_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "tar xf \"$file\""
    # tar xf "$file"
    # __handle_move "$file" "$output"
}

# rar
rar_pack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"
    __pack_with_cd "$file" "rar a -y \"$output.rar\" $(CS_VAR file)"
    # rar a -y "$output.rar" "$file"
}

rar_unpack() {
    local file="$(__decode_filename $1)"
    local output="$(__decode_filename $2)"

    __unpack_with_move "$file" "$output" "unrar x -y \"$file\""
    # unrar x -y "$file"
    # __handle_move "$file" "$output"
}
