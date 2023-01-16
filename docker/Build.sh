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
  -DHAVE_READLINE \
  -DSQLITE_CORE \
  -DSQLITE_DQS=0 \
  -DSQLITE_DEFAULT_MEMSTATUS=0 \
  -DSQLITE_ENABLE_COLUMN_METADATA \
  -DSQLITE_ENABLE_DBSTAT_VTAB \
  -DSQLITE_ENABLE_EXPLAIN_COMMENTS \
  -DSQLITE_ENABLE_FTS3 \
  -DSQLITE_ENABLE_FTS3_PARENTHESIS \
  -DSQLITE_ENABLE_FTS3_TOKENIZER \
  -DSQLITE_ENABLE_FTS4 \
  -DSQLITE_ENABLE_FTS5 \
  -DSQLITE_ENABLE_GEOPOLY \
  -DSQLITE_ENABLE_JSON1 \
  -DSQLITE_ENABLE_LOAD_EXTENSION=1 \
  -DSQLITE_ENABLE_MATH_FUNCTIONS \
  -DSQLITE_ENABLE_PREUPDATE_HOOK \
  -DSQLITE_ENABLE_RTREE \
  -DSQLITE_ENABLE_STAT4 \
  -DSQLITE_ENABLE_SESSION \
  -DSQLITE_ENABLE_UNLOCK_NOTIFY \
  -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT \
  -DSQLITE_LIKE_DOESNT_MATCH_BLOBS \
  -DSQLITE_MAX_ATTACHED=125 \
  -DSQLITE_MAX_COLUMN=32767 \
  -DSQLITE_MAX_LENGTH=2147483647 \
  -DSQLITE_MAX_MMAP_SIZE=1099511627776 \
  -DSQLITE_MAX_PAGE_COUNT=4294967294 \
  -DSQLITE_MAX_SCHEMA_RETRY=25 \
  -DSQLITE_MAX_SQL_LENGTH=1073741824 \
  -DSQLITE_MAX_VARIABLE_NUMBER=250000 \
  -DSQLITE_MAX_WORKER_THREADS=16 \
  -DSQLITE_THREADSAFE=1 \
  -DSQLITE_USE_ALLOCA \
  shell.c sqlite3.c \
  -static -lm \
  -lreadline \
  -lncursesw \
  -pthread \
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
