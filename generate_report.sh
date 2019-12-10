#!/bin/bash

TARGET_DIR=./data/minio/data/mybucket/

# listup DATA
for file in `\find ${TARGET_DIR} -maxdepth 1 -type d`; do
  echo "{$file}"
  # TODO:
  # docker run .....
done
