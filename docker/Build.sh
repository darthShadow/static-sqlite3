#!/bin/sh

src="${1}"
arch="${src##*/}"
workdir="${arch%.*}"


if [ ! -f "${arch}" ]; then
  wget -c "${src}"
  [ $? -ne 0 ] && {
    echo "===== FAILED ....... ==========================================================="
    printf "Can not download: %s\n\n" "${src}"
    exit 1
  }
fi

[ ! -f "${workdir}/sqlite3.c" ] && unzip ${arch}

cd "${workdir}"

printf "\n\n===== Compiling... Please wait... ==============================================\n\n"

# On apline use ncursesw instead of ncurses (!!!)
gcc \
  -Os \
  -DHAVE_USLEEP \
  -DSQLITE_DQS=0 \
  -DHAVE_READLINE \
  -DSQLITE_USE_ALLOCA \
  -DSQLITE_ENABLE_FTS4 \
  -DSQLITE_ENABLE_FTS5 \
  -DSQLITE_ENABLE_JSON1 \
  -DSQLITE_THREADSAFE=0 \
  -DSQLITE_ENABLE_RTREE \
  -DSQLITE_OMIT_DECLTYPE \
  -DSQLITE_ENABLE_GEOPOLY \
  -DSQLITE_OMIT_DEPRECATED \
  -DSQLITE_OMIT_SHARED_CACHE \
  -DSQLITE_OMIT_LOAD_EXTENSION \
  -DSQLITE_ENABLE_MATH_FUNCTIONS \
  -DSQLITE_OMIT_PROGRESS_CALLBACK \
  -DSQLITE_LIKE_DOESNT_MATCH_BLOBS \
  -DSQLITE_ENABLE_EXPLAIN_COMMENTS \
  shell.c sqlite3.c \
  -static -lm \
  -lreadline \
  -lncursesw \
  -o sqlite3

rc=$?
if [ $rc -eq 0 ]; then
  cp sqlite3 sqlite3_orig   # Keep naked, unstripped, unpacked version
  echo "===== Stripping... ============================================================="
  strip --strip-unneeded sqlite3
  if [ -n "${2}" ]; then
    echo "===== Compressing... ==========================================================="
    $2 sqlite3
  fi
else
  echo "================================ FAILED to compile ============================="
  exit 1
fi

echo "===================================== Done ====================================="

exit 0
