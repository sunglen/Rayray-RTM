# build rayray-rtm for ti-processor-sdk-linux-j7-evm-08_00_00_08

> a lot of binaries coded absolute path by `--prefix=` through installation. for distribution, it's better to set `--prefix=/opt/rayray/aarch64` than `--prefix=/home/s/rayray/aarch64`.

## python version

- host: python3.8

install python3.8 to host:

```
sudo apt install python3.8 libpython3.8-dev
```

it will install all necessary libraries, to uninstall:

```
sudo apt remove libpython3.8 libpython3.8-dev libpython3.8-minimal libpython3.8-stdlib python3.8 python3.8-dev python3.8-minimal
```
- target: python3.8

install ipk packages if not exist in targetfs.

## cross build on host (x86_64)

### build dependencies

```
cd pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/yocto-build/build/
TOOLCHAIN_BASE=/opt/ MACHINE=j7-evm bitbake boost -c clean
TOOLCHAIN_BASE=/opt/ MACHINE=j7-evm bitbake boost
```

after built:

```
$ ls arago-tmp-external-arm-glibc/deploy/ipk/aarch64/*boost*
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-dbg_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-dev_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-log_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-math_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-serialization_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-src_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-staticdev_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-test_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-atomic1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-chrono1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-container1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-context1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-contract1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-coroutine1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-date-time1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-filesystem1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-graph1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-iostreams1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-locale1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-program-options1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-python38-1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-random1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-regex1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-system1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-thread1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-timer1.72.0_1.72.0-r0.0_aarch64.ipk
arago-tmp-external-arm-glibc/deploy/ipk/aarch64/libboost-wave1.72.0_1.72.0-r0.0_aarch64.ipk
```

- `boost-dev` include all `*.hpp` header files.
- `boost-staticdev` include all `*.a` static library files.

### update targetfs

```
cd ~/pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/
cp yocto-build/build/arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-dev_1.72.0-r0.0_aarch64.ipk targetfs/home/root/
cp yocto-build/build/arago-tmp-external-arm-glibc/deploy/ipk/aarch64/boost-staticdev_1.72.0-r0.0_aarch64.ipk targetfs/home/root/
```

method 1: boot tda4 to targetfs as nfs.

```
root@j7-evm:~# opkg install boost-dev_1.72.0-r0.0_aarch64.ipk
root@j7-evm:~# opkg install boost-staticdev_1.72.0-r0.0_aarch64.ipk
```

method 2: use qemu. verified.

```
$ sudo cp /usr/bin/qemu-aarch64-static targetfs/usr/bin/qemu-aarch64-static
$ ./ch-mount.sh -m /home/s/pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/targetfs/
# opkg install boost-dev_1.72.0-r0.0_aarch64.ipk
# opkg install boost-staticdev_1.72.0-r0.0_aarch64.ipk
# exit
$ ./ch-mount.sh -u /home/s/pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/targetfs/
```

### build omniORB-4.2.3

> NOTE: latest version of omniORB (4.3.0 so far) may incompatible with OpenRTM-aist-1.2.0 or OpenRTM-aist-1.2.2. install version 4.2.3.

> NOTE: install `openssl-dev_1.1.1k-r0.0_aarch64.ipk` and `openssl-staticdev_1.1.1k-r0.0_aarch64.ipk` to targetfs if not yet.

build x86 tools:

```
cd /home/s/rayray/
tar -xvf omniORB-4.2.3.tar.bz2 
cd omniORB-4.2.3/
./configure --prefix=/home/s/rayray/x86_64 --with-openssl
make
make install
make clean
make veryclean
```

please note, `make clean` or `make veryclean` is a must.

prepare:

```
cp ../build-tda4/config.guess bin/scripts/
cp ../build-tda4/config.sub bin/scripts/
export PATH=/home/s/rayray/x86_64/bin:$PATH
mkdir build_aarch64
sudo mkdir -p /opt/rayray/aarch64
sudo chown $USER:$USER /opt/rayray/aarch64
```

source shell environment file:

```
cd build_aarch64
. ../../build-tda4/environment-setup-aarch64-simple
```

run configure script:

```
../configure --target=aarch64-linux --host=aarch64-linux --build=x86_64-linux \
--with-openssl OPENSSL_CFLAGS=-I/home/s/pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/targetfs/usr/include/ \
OPENSSL_LIBS=-L/home/s/pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/targetfs/usr/lib/ \
--prefix=/opt/rayray/aarch64 PYTHON=/usr/bin/python3.8
```

> NOTE: `/usr/bin/python3.8` is python path for target. `omniidl` of target will use this path.

> NOTE: if checking result is `checking whether the compiler supports ISO C++ standard library... yes`, it's unnecessary to add `-DHAVE_STD=1` to `CPPFLAGS`.

build and install lib, build and install appl:

```
make
make install
cd src/appl/
make
make install
```

fix `mk/python.mk`:

(e.g. `python3-dev` was installed to `/home/s/pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/targetfs/usr/include/python3.8/`)

set `PYVERSION`, `PYPREFIX`, `PYINCDIR` and `PythonSHAREDLIB_SUFFIX`, most of them can be defined by run python3.8 commands on target.

install tool:

```
cd ../..
cp ../../build-tda4/omniORB-4.2.3-mk-python.mk ../mk/python.mk
cd src/tool
make
make install
```

### build OpenRTM-aist-1.2.2

after building omniORB-4.2.3:

```
cd /home/s/rayray/OpenRTM-aist-1.2.2
. ../build-tda4/environment-setup-aarch64-simple
./configure --target=aarch64-linux --host=aarch64-linux --build=x86_64-linux \
--with-sysroot=/home/s/pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/targetfs \
--prefix=/opt/rayray/aarch64 \
--with-omniorb=/opt/rayray/aarch64 \
--without-artlinux --with-gnu-ld --enable-ssl --without-doxygen \
--enable-fluentd=no --enable-observer=yes
make
make install
```

## local build on target (aarch64)

### copy aarch64 dir from host to target.

copy `/opt/rayray/aarch64` from host to targetfs.

### check build dir on target

```
root@j7-evm:~/rayray# ls -p
OpenRTM-aist-Python-1.2.2/	  config.guess	environment-setup-aarch64  omniORBpy-4.2.3.tar.bz2  rtctree.git.tar.gz  rtshell.git.tar.gz  rtsprofile.git.tar.gz
OpenRTM-aist-Python-1.2.2.tar.gz  config.sub	omniORBpy-4.2.3/           rtctree/		    rtshell/	        rtsprofile/
```

### set build environment

```
root@j7-evm:~/rayray# . ./environment-setup-aarch64 
root@j7-evm:~/rayray# cat ./environment-setup-aarch64 
PLATFORM=aarch64
RTM_ROOT=/opt/rayray/$PLATFORM

export LD_LIBRARY_PATH=$RTM_ROOT/lib/:$LD_LIBRARY_PATH
export PYTHONPATH=$RTM_ROOT/lib/python3.8/site-packages/:$PYTHONPATH
export PATH=$RTM_ROOT/bin:$PATH
```

### build omniORBpy-4.2.3

adjust to the correct date and time for the target.

```
tar -xvf omniORBpy-4.2.3.tar.bz2 
cp config.guess config.sub omniORBpy-4.2.3/bin/scripts/
cd omniORBpy-4.2.3/
./configure --prefix=/opt/rayray/aarch64 --with-omniorb=/opt/rayray/aarch64
make
make install
```

### build OpenRTM-aist-Python-1.2.2

```
tar -xvf OpenRTM-aist-Python-1.2.2.tar.gz 
cd OpenRTM-aist-Python-1.2.2/
python3.8 setup.py build
python3.8 setup.py install --prefix=/opt/rayray/aarch64
```

### build rtctree

```
tar -xvf rtctree.git.tar.gz 
cd rtctree/
python3.8 setup.py build
python3.8 setup.py install --prefix=/opt/rayray/aarch64
```
`python3.8 setup.py install --prefix=/opt/rayray/aarch64` copied `rtctree_aist-4.2.3-py3.8.egg` only.

it's done for python3.8.

but for python2.7, must copy the following contents manually.

```
cp -r build/lib/rtctree/ /opt/rayray/aarch64/lib/python2.7/site-packages/
cp -r rtctree_aist.egg-info/ /opt/rayray/aarch64/lib/python2.7/site-packages/rtctree_aist-4.2.3-py2.7.egg-info
```

### build rtsprofile

```
tar -xvf rtsprofile.git.tar.gz 
cd rtsprofile/
python3.8 setup.py build
python3.8 setup.py install --prefix=/opt/rayray/aarch64
```

### build rtshell

fix `setup.py`: disable build and install documentation.

```
tar -xvf rtshell.git.tar.gz 
cd rtshell/
vi setup.py 
python3.8 setup.py build
python3.8 setup.py install --prefix=/opt/rayray/aarch64
```

### run first example

terminal 1:

```
. ~/rayray/environment-setup-aarch64
rtm-naming
/opt/rayray/aarch64/share/openrtm-1.2/components/c++/examples/ConsoleInComp
```

terminal 2:

```
/opt/rayray/aarch64/share/openrtm-1.2/components/c++/examples/ConsoleOutComp
```

terminal 3:

> `j7-evm.host_cxt` is the name of machine.

```
root@j7-evm:~# . rayray/environment-setup-aarch64 
root@j7-evm:~# rtls -R localhost
.:
j7-evm.host_cxt/

./j7-evm.host_cxt:
ConsoleIn0.rtc  ConsoleOut0.rtc

root@j7-evm:~# rtcon /localhost/j7-evm.host_cxt/ConsoleIn0.rtc:out /localhost/j7-evm.host_cxt/ConsoleOut0.rtc:in
root@j7-evm:~# rtact /localhost/j7-evm.host_cxt/ConsoleIn0.rtc /localhost/j7-evm.host_cxt/ConsoleOut0.rtc
```
### distribute

copy `environment-setup-aarch64` to `/opt/rayray/aarch64`, and zip the aarch64 dir to a tarball.

## official git repositories

- https://github.com/OpenRTM/rtctree
- https://github.com/OpenRTM/rtsprofile
- https://github.com/OpenRTM/rtshell

# build rayray-rtm for x86_64

## build dirs

```
$ ls -p
build/  dl/  r32.4.3/  r32.6.1/  README.md  x86_64/
$ ls -p dl
omniORB-4.2.3.tar.bz2  omniORBpy-4.2.3.tar.bz2  OpenRTM-aist-1.2.2.tar.gz  OpenRTM-aist-Python-1.2.2.tar.gz  rtctree.git.tar.gz  rtshell.git.tar.gz  rtsprofile.git.tar.gz
$ ls -p r32.4.3
aarch64/
```
## build omniORB-4.2.3

already done in the procedure above.

## build OpenRTM-aist-1.2.2

```
sudo apt install libssl-dev libboost-dev libboost-system-dev libboost-filesystem-dev libboost-thread-dev
sudo apt install uuid-dev
export PATH=/home/s/rayray/x86_64/bin:$PATH
cd OpenRTM-aist-1.2.0
export LDFLAGS="-lssl $LDFLAGS"
./configure --prefix=/home/s/rayray/x86_64 \
--with-omniorb=/home/s/rayray/x86_64 --without-artlinux --with-gnu-ld --enable-ssl --without-doxygen \
--enable-fluentd=no --enable-observer=yes
make
make install
```

## build omniORBpy-4.2.3

```
cd omniORBpy-4.2.3
./configure --prefix=/home/s/rayray/x86_64 --with-omniorb=/home/s/rayray/x86_64
make
make install
```

## build OpenRTM-aist-Python-1.2.2

```
cd OpenRTM-aist-Python-1.2.2
python setup.py install --prefix=/home/s/rayray/x86_64
```

## build rtctree

always use rtctree from the same official source along with rtshell. 

```
export LD_LIBRARY_PATH=/home/s/rayray/x86_64/lib/:$LD_LIBRARY_PATH
export PYTHONPATH=/home/s/rayray/x86_64/lib/python2.7/site-packages/:$PYTHONPATH
python setup.py build
python setup.py install --prefix=/home/s/rayray/x86_64 #copied rtctree_aist-4.2.3-py2.7.egg only
#bug here: must copy the following contents manually.
cp -r build/lib.linux-x86_64-2.7/rtctree/ ../x86_64/lib/python2.7/site-packages/
cp -r rtctree_aist.egg-info/ ../x86_64/lib/python2.7/site-packages/rtctree_aist-4.2.3-py2.7.egg-info
```
## build rtsprofile

```
python setup.py build
python setup.py install --prefix=/home/s/rayray/x86_64
cp -r build/lib.linux-x86_64-2.7/rtsprofile/ ../x86_64/lib/python2.7/site-packages/
cp -r rtsprofile_aist.egg-info/ ../x86_64/lib/python2.7/site-packages/rtsprofile_aist-4.1.5-py2.7.egg-info
```
## build rtshell

fix setup.py to adapt python2.7, and disable build/install documentation.

```
python setup.py build
python setup.py install --prefix=/home/s/rayray/x86_64
```
## run first example

terminal 1:

```
$ . ~/rayray/environment-setup-x86_64
$ rtm-naming
$ ~/rayray/x86_64/share/openrtm-1.2/components/c++/examples/ConsoleInComp
```

terminal 2:

```
$ ~/rayray/x86_64/share/openrtm-1.2/components/c++/examples/ConsoleOutComp
```

terminal 3:

> s-HP-Laptop-14s-cr2xxx.host_cxt is the name of machine.

```
$ . ~/rayray/environment-setup-x86_64
$ rtls -R localhost
.:
s-HP-Laptop-14s-cr2xxx.host_cxt/

./s-HP-Laptop-14s-cr2xxx.host_cxt:
ConsoleIn0.rtc  ConsoleOut0.rtc


$ rtcon /localhost/s-HP-Laptop-14s-cr2xxx.host_cxt/ConsoleIn0.rtc:out /localhost/s-HP-Laptop-14s-cr2xxx.host_cxt/ConsoleOut0.rtc:in

$ rtact /localhost/s-HP-Laptop-14s-cr2xxx.host_cxt/ConsoleIn0.rtc /localhost/s-HP-Laptop-14s-cr2xxx.host_cxt/ConsoleOut0.rtc

```

## first test for SDK 8.4

install rayray-rtm binaries to targetfs of 8.4:

```
cd ti-processor-sdk-linux-j7-evm-08_04_00_11/targetfs/opt
sudo tar xvf ~/rayray/dist/tda4-opt-rayray.tar.gz 
```

login tda4 of ip address 192.168.4.105.

tda4 terminal 1:

```
. /opt/rayray/environment-setup-aarch64
rtm-naming
/opt/rayray/aarch64/share/openrtm-1.2/components/c++/examples/ConsoleInComp
```

tda4 terminal 2:

```
/opt/rayray/aarch64/share/openrtm-1.2/components/c++/examples/ConsoleOutComp
```

tda4 terminal 3:

```
. /opt/rayray/environment-setup-aarch64
rtls -R localhost
.:
j7-evm.host_cxt/

./j7-evm.host_cxt:
ConsoleIn0.rtc  ConsoleOut0.rtc
```

connect and activate:

```
rtcon /localhost/j7-evm.host_cxt/ConsoleIn0.rtc:out /localhost/j7-evm.host_cxt/ConsoleOut0.rtc:in
rtact /localhost/j7-evm.host_cxt/ConsoleIn0.rtc /localhost/j7-evm.host_cxt/ConsoleOut0.rtc
```

deactivate and disconnect:

```
rtdeact /localhost/j7-evm.host_cxt/ConsoleIn0.rtc /localhost/j7-evm.host_cxt/ConsoleOut0.rtc
rtdis /localhost/j7-evm.host_cxt/ConsoleOut0.rtc:in
rtdis /localhost/j7-evm.host_cxt/ConsoleIn0.rtc:out
```

pc terminal 1:

```
. ~/rayray/environment-setup-x86_64
rtm-naming
~/rayray/x86_64/share/openrtm-1.2/components/c++/examples/ConsoleInComp
```

pc terminal 2:

```
rtls -R 192.168.4.105
.:
j7-evm.host_cxt/

./j7-evm.host_cxt:
ConsoleIn0.rtc  ConsoleOut0.rtc

rtls -R localhost
.:
s-HP-Laptop-14s-cr2xxx.host_cxt/

./s-HP-Laptop-14s-cr2xxx.host_cxt:
ConsoleIn0.rtc
```

connect and activate:

```
rtcon /localhost/s-HP-Laptop-14s-cr2xxx.host_cxt/ConsoleIn0.rtc:out /192.168.4.105/j7-evm.host_cxt/ConsoleOut0.rtc:in
rtact /localhost/s-HP-Laptop-14s-cr2xxx.host_cxt/ConsoleIn0.rtc /192.168.4.105/j7-evm.host_cxt/ConsoleOut0.rtc
```
