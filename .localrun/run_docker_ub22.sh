#! /bin/bash

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

echo $_HOME_
cd $_HOME_

if [ "$1""x" == "buildx" ]; then
    docker build -f Dockerfile_ub22 -t asan_borken_001_ub22 .
    exit 0
fi


mkdir -p $_HOME_/artefacts
mkdir -p $_HOME_/script

echo '#! /bin/bash

ls -al /work/
clang-13 -O0 -g /work/a.c  -fsanitize=address   -fsanitize-recover=address -o a
clang-14 -O0 -g /work/a.c  -fsanitize=address   -fsanitize-recover=address -o b

./a;./a;./a;./a;./a;./a;./a;./a;./a;./a
./b;./b;./b;./b;./b;./b;./b;./b;./b;./b

' > $_HOME_/script/do_it___external.sh

chmod a+rx $_HOME_/script/do_it___external.sh
system_to_build_for="ubuntu:22.04"
cd $_HOME_/
docker run -ti --rm \
  -v $_HOME_/artefacts:/artefacts \
  -v $_HOME_/script:/script \
  -v $_HOME_/../:/work \
  -e DISPLAY=$DISPLAY \
  "asan_borken_001_ub22" \
  /bin/sh -c "apk add bash >/dev/null 2>/dev/null; /bin/bash /script/do_it___external.sh"

