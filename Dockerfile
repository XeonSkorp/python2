CMD ["/bin/ash" "/entrypoint.sh"]
COPY file:a276d078d6d4ee96415c71ef6f631b51d73017ecf11c2a0e6be9aa477b47262d in /entrypoint.sh
WORKDIR /home/container
ENV USER=container HOME=/home/container
USER [container]
RUN apk add --no-cache --update && adduser -D -h /home/container container
LABEL author=Michael Parker maintainer=docker@parkervcp.com
CMD ["python2"]
RUN set -ex; wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION" ; pip --version; find /usr/local -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' +; rm -f get-pip.py
ENV PYTHON_PIP_VERSION=18.1
RUN cd /usr/local/bin && ln -s idle3 idle && ln -s pydoc3 pydoc && ln -s python2 python && ln -s python2-config python-config
RUN set -ex && apk add --no-cache --virtual .fetch-deps gnupg tar xz && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" && export GNUPGHOME="$(mktemp -d)" && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" && gpg --batch --verify python.tar.xz.asc python.tar.xz && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } && rm -rf "$GNUPGHOME" python.tar.xz.asc && mkdir -p /usr/src/python && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz && rm python.tar.xz && apk add --no-cache --virtual .build-deps bzip2-dev coreutils dpkg-dev dpkg expat-dev findutils gcc gdbm-dev libc-dev libffi-dev libnsl-dev libressl-dev libtirpc-dev linux-headers make ncurses-dev pax-utils readline-dev sqlite-dev tcl-dev tk tk-dev util-linux-dev xz-dev zlib-dev && apk del .fetch-deps && cd /usr/src/python && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && ./configure --build="$gnuArch" --enable-loadable-sqlite-extensions --enable-shared --with-system-expat --with-system-ffi --without-ensurepip && make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" && make install && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' | xargs -rt apk add --no-cache --virtual .python-rundeps && apk del .build-deps && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' + && rm -rf /usr/src/python && python2 --version
ENV PYTHON_VERSION=2.7.17
ENV GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
RUN apk add --no-cache ca-certificates
ENV LANG=C.UTF-8
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
CMD ["/bin/sh"]
ADD file:25c10b1d1b41d46a1827ad0b0d2389c24df6d31430005ff4e9a2d84ea23ebd42 in /