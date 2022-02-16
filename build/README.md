# build rayray-rtm for L4T r32.6.1

> if do not want to build from scratch

>> run `pkg_install_ubuntu.sh` (with parameters, see www.openrtm.org for details) on both host(x86_64) and target(aarch64).

> for L4T R32.4.3

>> also work for L4T R32.4.3 of Nvidia Jetson devices, just change rootfs related path settings.

> bugs

>> a lot of binaries coded absolute path by `--prefix=` through installation, therefore, for distribution, 
>> it's better to set `--prefix=/opt/rayray/aarch64` other than `--prefix=/home/s/rayray/aarch64`.

## build on host (x86_64)

### python version

python2.7

### update rootfs

```
$ sudo mount -o loop /media/s/A872A69772A66A30/hy/4.6/system.img.raw /opt/s/titan4-bsp-r32.6.1/out/Linux_for_Tegra/rootfs/
$ cd /opt/s/titan4-bsp-r32.6.1
$ sudo cp /usr/bin/qemu-aarch64-static out/Linux_for_Tegra/rootfs/usr/bin/qemu-aarch64-static #if not performed
$ ./ch-mount.sh -m /opt/s/titan4-bsp-r32.6.1/out/Linux_for_Tegra/rootfs/
# cat /etc/resolv.conf 
nameserver 8.8.8.8
search nvidia.com
# cat /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
deb https://repo.download.nvidia.com/jetson/common r32.6 main
deb https://repo.download.nvidia.com/jetson/t194 r32.6 main
# apt update
# date
Fri Feb 11 16:43:04 UTC 2022
# apt --reinstall install ca-certificates
# apt install nvidia-jetpack
# apt install libssl-dev libboost-dev libboost-system-dev libboost-filesystem-dev libboost-thread-dev
# apt install libpython-dev
# exit
$ ./ch-mount.sh -u /opt/s/titan4-bsp-r32.6.1/out/Linux_for_Tegra/rootfs/
```

### build omniORB-4.2.3

> omniORB-4.3.0 (latest version so far) may incompatible with OpenRTM-aist-1.2.0 or OpenRTM-aist-1.2.2.

```
cd /home/s/rayray/
tar -xvf omniORB-4.2.3.tar.bz2 
cd omniORB-4.2.3/
cp ~/TITAN4_BSP/doc/config.guess bin/scripts/
cp ~/TITAN4_BSP/doc/config.sub bin/scripts/
./configure --prefix=/home/s/rayray/x86_64 --with-openssl
make
make install
make clean
make veryclean
export PATH=/home/s/rayray/x86_64/bin:$PATH
mkdir build_aarch64
cd build_aarch64
. /opt/s/titan4-bsp-r32.6.1/environment-setup-aarch64
../configure --target=aarch64-linux-gnu --host=aarch64-linux-gnu --build=x86_64-linux \
--with-openssl OPENSSL_CFLAGS=-I/opt/s/titan4-bsp-r32.6.1/out/Linux_for_Tegra/rootfs/usr/include/ \
OPENSSL_LIBS=-L/opt/s/titan4-bsp-r32.6.1/out/Linux_for_Tegra/rootfs/usr/lib/aarch64-linux-gnu/ \
--prefix=/home/s/rayray/aarch64
make
make install
cd src/appl/
make
make install
cd ../..
cd src/tool #need libpython-dev in rootfs
make
make install
```

### fix broken symbolic links in BSP's rootfs

```
. /opt/s/titan4-bsp-r32.6.1/environment-setup-aarch64 #if not performed
cd $SDKTARGETSYSROOT/usr/lib/aarch64-linux-gnu/
sudo rm libm.so
sudo ln -s ../../../lib/aarch64-linux-gnu/libm.so.6 libm.so
sudo rm librt.so
sudo ln -s ../../../lib/aarch64-linux-gnu/librt.so.1 librt.so
sudo rm libdl.so
sudo ln -s ../../../lib/aarch64-linux-gnu/libdl.so.2 libdl.so
```

### build OpenRTM-aist-1.2.0

after building omniORB-4.2.3:

```
cd /home/s/rayray/
tar -zxvf OpenRTM-aist-1.2.0.tar.gz
cd OpenRTM-aist-1.2.0
. /opt/s/titan4-bsp-r32.6.1/environment-setup-aarch64 #if not performed
export LDFLAGS="-lssl $LDFLAGS"
./configure --target=aarch64-linux-gnu --host=aarch64-linux-gnu --build=x86_64-linux \
--with-sysroot=/opt/s/titan4-bsp-r32.6.1/out/Linux_for_Tegra/rootfs --prefix=/home/s/rayray/aarch64 \
--with-omniorb=/home/s/rayray/aarch64 --without-artlinux --with-gnu-ld --enable-ssl --without-doxygen
make
make install
```

### build OpenRTM-aist-1.2.2

after building omniORB-4.2.3:

```
cd /home/s/rayray/OpenRTM-aist-1.2.2
. /opt/s/titan4-bsp-r32.6.1/environment-setup-aarch64 #if not performed
export LDFLAGS="-lssl $LDFLAGS"
./configure --target=aarch64-linux-gnu --host=aarch64-linux-gnu --build=x86_64-linux \
--with-sysroot=/opt/s/titan4-bsp-r32.6.1/out/Linux_for_Tegra/rootfs --prefix=/home/s/rayray/aarch64 \
--with-omniorb=/home/s/rayray/aarch64 --without-artlinux --with-gnu-ld --enable-ssl --without-doxygen \
--enable-fluentd=no --enable-observer=yes
make
make install
```

## build on target (aarch64)

### copy aarch64 dir from host to target.

```
$ scp -r /home/s/rayray/aarch64 s@192.168.4.101:/home/s/rayray/
```

### python version

python2.7

### build dir

```
$ cd /home/s/rayray/
$ ls -p
aarch64/      config.sub        omniORBpy-4.2.3.tar.bz2     OpenRTM-aist-Python-1.2.2.tar.gz  rtshell/     set-rtshell-env
config.guess  omniORBpy-4.2.3/  OpenRTM-aist-Python-1.2.2/  rtctree/                          rtsprofile/
```
### set build environment

```
$ . environment-setup-aarch64
$ cat environment-setup-aarch64 
PLATFORM=aarch64
RTM_ROOT=$HOME/rayray/$PLATFORM

export LD_LIBRARY_PATH=$RTM_ROOT/lib/:$LD_LIBRARY_PATH
export PYTHONPATH=$RTM_ROOT/lib/python2.7/site-packages/:$PYTHONPATH
export PATH=$RTM_ROOT/bin:$PATH
```

### build omniORBpy-4.2.3

```
cp config.guess config.sub omniORBpy-4.2.3/bin/scripts/
cd omniORBpy-4.2.3
./configure --prefix=/home/s/rayray/aarch64 --with-omniorb=/home/s/rayray/aarch64
make
make install
```

### build OpenRTM-aist-Python-1.2.2

```
cd /home/s/rayray/OpenRTM-aist-Python-1.2.2
python setup.py build
sudo python setup.py install
```

install to /usr/local/lib/python2.7/dist-packages/

or better, make it portable:

```
python setup.py install --prefix=~/rayray/aarch64
```

install to dir which use `~/rayray/aarch64` as root.

### build rtctree

do not use sudo for build, if su to root, should also set build environment before build/install.

```
cd /home/s/rayray/rtctree
python setup.py build
```

if build rtctree successfully: 

```
cd /home/s/rayray/rtctree
$ ls build/lib.linux-aarch64-2.7/rtctree/rtc/
BasicDataType_idl.py      ExtendedDataTypes_idl.py   InterfaceDataTypes_idl.py  OpenRTM         RTC         RTM         SDOPackage_idl.py
ComponentObserver_idl.py  ExtendedFsmService_idl.py  Logger_idl.py              OpenRTM_idl.py  RTC_idl.py  RTM__POA    SDOPackage__POA
DataPort_idl.py           __init__.py                Manager_idl.py             OpenRTM__POA    RTC__POA    SDOPackage
```

install:

```
python setup.py install --prefix=~/rayray/aarch64 #copied rtctree_aist-4.2.3-py2.7.egg only
#bug here: must copy the following contents manually.
cp -r build/lib.linux-aarch64-2.7/rtctree/ ../aarch64/lib/python2.7/site-packages/
cp -r rtctree_aist.egg-info/ ../aarch64/lib/python2.7/site-packages/rtctree_aist-4.2.3-py2.7.egg-info
```

### build rtsprofile

```
cd /home/s/rayray/rtsprofile
python setup.py build
python setup.py install --prefix=~/rayray/aarch64
cp -r build/lib.linux-aarch64-2.7/rtsprofile/ ../aarch64/lib/python2.7/site-packages/
cp -r rtsprofile_aist.egg-info/ ../aarch64/lib/python2.7/site-packages/rtsprofile_aist-4.1.5-py2.7.egg-info
```

### build rtshell

fix setup.py to adapt python2.7.

```
cd /home/s/rayray/rtshell
python setup.py build
python setup.py install --prefix=~/rayray/aarch64
```

### fix rtctree (obsolete)

> the fix is obsolete and unnecessary since all parts have been installed to `~/rayray/aarch64`.

if rtshell (rtls, rtcon, ...) is not available due to the following error: `ImportError: No module named rtc`:

```
export PYTHONPATH=/home/s/rayray/rtctree/build/lib.linux-aarch64-2.7/:$PYTHONPATH
```

or copy rtctree to exist PYTHONPATH manually.

### run first example

terminal 1:

```
$ . ~/rayray/set-env
$ rtm-naming
$ ~/rayray/aarch64/share/openrtm-1.2/components/c++/examples/ConsoleInComp
```

terminal 2:

```
$ ~/rayray/aarch64/share/openrtm-1.2/components/c++/examples/ConsoleOutComp
```

terminal 3:

> linux.host_cxt is the name of machine.

```
$ . ~/rayray/set-env
$ rtls -R localhost
.:
linux.host_cxt/

./linux.host_cxt:
ConsoleIn0.rtc  ConsoleOut0.rtc

$ rtcon /localhost/linux.host_cxt/ConsoleIn0.rtc:out /localhost/linux.host_cxt/ConsoleOut0.rtc:in

$ rtact /localhost/linux.host_cxt/ConsoleIn0.rtc /localhost/linux.host_cxt/ConsoleOut0.rtc

```

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
