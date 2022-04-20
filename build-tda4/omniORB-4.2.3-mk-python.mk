#############################################################################
#   Make variables for building Python modules                              #
#############################################################################

#PYVERSION := $(shell $(PYTHON) -c 'import sys; sys.stdout.write(sys.version[:3])')
PYVERSION := 3.8
#PYPREFIX  := $(shell $(PYTHON) -c 'import sys; sys.stdout.write(sys.exec_prefix.replace("\\","/"))')
PYPREFIX  := /usr
#PYINCDIR  := $(shell $(PYTHON) -c 'import sys, distutils.sysconfig; sys.stdout.write(distutils.sysconfig.get_python_inc().replace("\\","/"))')
#PYINCDIR  := /usr/include/python3.8
PYINCDIR  := /home/s/pallas/ti-processor-sdk-linux-j7-evm-08_00_00_08/targetfs/usr/include/python3.8
#PythonSHAREDLIB_SUFFIX = $(shell $(PYTHON) -c 'import sys, distutils.sysconfig; sys.stdout.write((distutils.sysconfig.get_config_var("SO") or ".so").lstrip("."))')

PythonSHAREDLIB_SUFFIX = cpython-38-aarch64-linux-gnu.so

#PY_MODULE_SUFFIX := $(shell $(PYTHON) -c 'import sys; sys.stdout.write((sys.hexversion < 0x3000000) and "module" or "")')

PY_MODULE_SUFFIX := 

PYINCFILE := "<Python.h>"
PYINCTHRD := "<pythread.h>"

DIR_CPPFLAGS += -I$(PYINCDIR) -DPYTHON_INCLUDE=$(PYINCFILE) -DPYTHON_THREAD_INC=$(PYINCTHRD)
