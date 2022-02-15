#!/bin/sh
#
# @file pkg_install_ubuntu.sh
# @brief OpenRTM-aist dependent packages install script for Ubuntu
# @author Noriaki Ando <n-ando@aist.go.jp>
#         Shinji Kurihara
#         Tetsuo Ando
#         Harumi Miyamoto
#         Seisho Irie
#         Nobu   Kawauchi
#
# Global variables
# 
# - OPT_RUNTIME  : installing runtime packages
# - OPT_DEVEL    : installing developers' staff
# - OPT_SRCPKG   : installing tools for make source package
# - OPT_COREDEVEL: installing tools for core developers
# = OPT_UNINST   : uninstallation
#

VERSION=2.0.0.08

#
#---------------------------------------
# usage
#---------------------------------------
usage()
{
  cat <<EOF
  Usage: 

    $(basename ${0}) -l {all|c++} [-r|-d|-s|-c] [-t OpenRTM-aist old version number] [-u|--yes]
    $(basename ${0}) [-u]
    $(basename ${0}) -l {python} [-r|-d|-c] [-t OpenRTM-aist old version number] [-u|--yes]
    $(basename ${0}) -l {java} [-r|-d|-c] [-u|--yes]
    $(basename ${0}) -l {openrtp|rtshell} [-d] [-u|--yes]
    $(basename ${0}) {--help|-h|--version}

  Example:
    $(basename ${0}) [= $(basename ${0}) -l all -d]
    $(basename ${0}) -l all -d
    $(basename ${0}) -l c++ -c --yes
    $(basename ${0}) -l all -u
    $(basename ${0}) -l all -d -t 1.2.1

  Options:
    -l <argument>  language or tool [c++|python|java|openrtp|rtshell|all]
	all        install packages of all the supported languages and tools
                   (openrtp is not supported in aarch64 environment.)
    -r             install robot component runtime
    -d             install robot component developer [default]
    -t <argument>  OpenRTM-aist old version number
    -s             install tool_packages for build source packages
    -c             install tool_packages for core developer
    -u             uninstall packages
    --yes          force yes
    --help, -h     print this
    --version      print version number
EOF
}

version()
{
  echo ${VERSION}
}


#---------------------------------------
# パッケージリスト
#---------------------------------------
ace="libace libace-dev"
openrtm04="openrtm-aist=0.4.2-1 openrtm-aist-doc=0.4.2-1 openrtm-aist-dev=0.4.2-1 openrtm-aist-example=0.4.2-1 python-yaml"

default_reposerver="openrtm.org"
reposervers="openrtm.org"
reposerver=""

RTM_OLD_VER=1.2.1
old_openrtm_devel="openrtm-aist-doc=$RTM_OLD_VER-0 openrtm-aist-idl=$RTM_OLD_VER-0 openrtm-aist-dev=$RTM_OLD_VER-0"
old_openrtm_runtime="openrtm-aist=$RTM_OLD_VER-0 openrtm-aist-example=$RTM_OLD_VER-0"
old_openrtm_py_devel="openrtm-aist-python-doc=$RTM_OLD_VER-0"
old_openrtm_py_runtime="openrtm-aist-python=$RTM_OLD_VER-0 openrtm-aist-python-example=$RTM_OLD_VER-0"

ARCH=`arch`
#--------------------------------------- C++
autotools="autoconf libtool libtool-bin"
base_tools="bc iputils-ping net-tools"
common_devel="python3-yaml"
cxx_devel="gcc g++ make $common_devel"
cmake_tools="cmake doxygen graphviz nkf"
build_tools="subversion git"
deb_pkg="uuid-dev libboost-filesystem-dev"
pkg_tools="build-essential debhelper devscripts"
omni_devel="libomniorb4-dev omniidl"
omni_runtime="omniorb-nameserver"
openrtm_devel="openrtm-aist-doc openrtm-aist-idl openrtm-aist-dev"
openrtm_runtime="openrtm-aist openrtm-aist-example"

#--------------------------------------- Python
omnipy="omniidl-python3"
python_runtime="python3 python3-omniorb-omg"
python_devel="python3-pip $cmake_tools $base_tools $omnipy $common_devel"
res=`grep 16.04 /etc/lsb-release`
if test ! "x$res" = "x" ||
   test "x${ARCH}" = "xaarch64" ; then
  # 16.04, aarch64
  openrtm_py_devel=""
else
  openrtm_py_devel="openrtm-aist-python3-doc"
fi
openrtm_py_runtime="openrtm-aist-python3 openrtm-aist-python3-example"

#--------------------------------------- Java
java_build="ant"
openrtm_j_devel="openrtm-aist-java-doc"
openrtm_j_runtime="openrtm-aist-java openrtm-aist-java-example"

#--------------------------------------- OpenRTP
openrtp_pkgs="openrtp"

#---------------------------------------
# Script options, argument analysis
#---------------------------------------
init_param()
{
OPT_RUNTIME=false
OPT_DEVEL=false
OPT_SRCPKG=false
OPT_COREDEVEL=false
OPT_UNINST=true
OPT_OLD_RTM=false
install_pkgs=""
uninstall_pkgs=""
arg_all=false
arg_cxx=false
arg_python=false
arg_java=false
arg_openrtp=false
arg_rtshell=false
err_message=""
}


check_arg()
{
  local arg=$1
  arg_err=0
  
  case "$arg" in
    all ) arg_all=true ;;
    c++ ) arg_cxx=true ;;
    python ) arg_python=true ;;
    java ) arg_java=true ;;
    openrtp ) arg_openrtp=true ;;
    rtshell ) arg_rtshell=true ;;
    *) arg_err=-1 ;;
  esac

  if test "x${ARCH}" = "xaarch64"; then
    arg_openrtp=false
    echo "[wARNING] openrtp is not supported in aarch64 environment."
  fi
}

set_old_rtm_pkgs()
{
  local ver=$1 LF='\n'
  local msg tmp
  arg_err=""

  if test "x$ver" = "x$RTM_OLD_VER" ; then
    OPT_OLD_RTM=true
    if test "x$arg_cxx" = "xtrue" ||
       test "x$arg_all" = "xtrue" ; then
      openrtm_devel=$old_openrtm_devel
      openrtm_runtime=$old_openrtm_runtime
      arg_cxx=true
    fi
    if test "x$arg_python" = "xtrue" ||
       test "x$arg_all" = "xtrue"    ; then
      omnipy="omniidl-python"
      python_runtime="python python-omniorb-omg"
      python_devel="python-pip $cmake_tools $base_tools $omnipy"
      openrtm_py_devel=$old_openrtm_py_devel
      openrtm_py_runtime=$old_openrtm_py_runtime
      arg_python=true
    fi
    if test "x$arg_java" = "xtrue" ||
       test "x$arg_all" = "xtrue" ; then
      msg="[ERROR] Installation of older version of OpenRTM-aist-Java is not supported."
      echo $msg
      tmp="$err_message$LF$msg"
      err_message=$tmp
      arg_java=false
    fi
    if test "x$arg_openrtp" = "xtrue" ||
       test "x$arg_all" = "xtrue" ; then
      msg="[ERROR] Installation of older version of OpenRTP-aist is not supported."
      echo $msg
      tmp="$err_message$LF$msg"
      err_message=$tmp
      arg_openrtp=false
    fi
    if test "x$arg_rtshell" = "xtrue" ||
       test "x$arg_all" = "xtrue" ; then
      msg="[ERROR] Installation of older version of rtshell is not supported."
      echo $msg
      tmp="$err_message$LF$msg"
      err_message=$tmp
      arg_rtshell=false
    fi
  else
    arg_err=$ver
  fi
}

get_opt()
{ 
  # オプション指定が無い場合のデフォルト設定
  if [ $# -eq 0 ] ; then
    arg_all=true
    OPT_DEVEL=true
  fi
  arg_num=$#
 
  OPT=`getopt -o l:rcsdt:hu -l help,yes,version -- $@` > /dev/null 2>&1
  # return code check
  if [ $? -ne 0 ] ; then
    echo "[ERROR] Invalid option '$1'"
    usage
    exit
  fi
  # 引数1個の場合
  if [ $arg_num -eq 1 ] ; then
    # オプション指定が -r/-s/-c のみの場合
    if test "x$1" = "x-r" ||
       test "x$1" = "x-s" ||
       test "x$1" = "x-c" ; then
      echo "[ERROR] Invalid option '$1'. '-l' option is required."
      usage
      exit
    fi
    if test "x$1" = "x--yes" ; then
      arg_all=true
      OPT_DEVEL=true
    fi
  fi
  eval set -- $OPT

  while true
  do
    case "$1" in
        -h|--help ) usage ; exit ;;
        --version ) version ; exit ;;
        --yes ) FORCE_YES=true ;;
        -l )  if [ -z "$2" ] ; then
                echo "$1 option requires an argument." 1>&2
                exit
              fi
              check_arg $2
              if [ "$arg_err" = "-1" ]; then
                echo "[ERROR] Invalid argument '$2'"
                usage
                exit
              fi
              shift ;;
        -t )  if [ -z "$2" ] ; then
                echo "$1 option requires an argument." 1>&2
                exit
              fi
              set_old_rtm_pkgs $2
              if test ! "x$arg_err" = "x" ; then
                echo "[ERROR] Invalid argument '$2'. Only $RTM_OLD_VER supported. "
                exit
              fi
              shift ;;
        -r )  OPT_RUNTIME=true ;;
        -d )  OPT_DEVEL=true ;;
        -s )  OPT_SRCPKG=true ;;
        -c )  OPT_COREDEVEL=true ;;
        -u )  OPT_UNINST=false ;;
        -- ) shift ; break ;;                 
        * )
          echo "Internal Error" 1>&2
          exit ;;
    esac
    shift
  done

  # オプション指定が -u のみの場合
  if [ $arg_num -eq 1 ] ; then
    if test "x$OPT_UNINST" = "xfalse" ; then 
      arg_all=true
    fi
  fi
}

#---------------------------------------
# ロケールの言語確認
#---------------------------------------
check_lang()
{
lang="en"

locale | grep ja_JP > /dev/null && lang="jp"

if test "$lang" = "jp" ;then
    msg1="ディストリビューションを確認してください。\nDebianかUbuntu以外のOSの可能性があります。"
    msg2="コードネーム :"
    msg3="このOSはサポートしておりません。"
    msg4="OpenRTM-aist のリポジトリが登録されていません。"
    msg5="Source.list に OpenRTM-aist のリポジトリ: "
    msg6="を追加します。よろしいですか？(y/n)[y] "
    msg7="中断します。"
    msg8="ルートユーザーで実行してください。"
    msg9="インストール中です..."
    msg10="完了"
    msg11="アンインストール中です."
else
    msg1="This distribution may not be debian/ubuntu."
    msg2="The code name is : "
    msg3="This OS is not supported."
    msg4="No repository entry for OpenRTM-aist is configured in your system."
    msg5="repository entry for OpenRTM-aist: "
    msg6="Do you want to add new repository entry for OpenRTM-aist in source.list? (y/n) [y] "
    msg7="Abort."
    msg8="This script should be run as root."
    msg9="Now installing: "
    msg10="done."
    msg11="Now uninstalling: "
fi

}

#----------------------------------------
# 近いリポジトリサーバを探す
#----------------------------------------
check_reposerver()
{
  minrtt=65535
  nearhost=''
  for host in $reposervers; do
    rtt=`ping -c 1 $host | grep 'time=' | sed -e 's/^.*time=\([0-9\.]*\) ms.*/\1/' 2> /dev/null`
    if test "x$rtt" = "x"; then
      rtt=65535
    fi
    if test `echo "scale=2 ; $rtt < $minrtt" | bc` -gt 0; then
      minrtt=$rtt
      nearhost=$host
    fi
  done
  if test "x$nearhost" = "x"; then
    echo "Repository servers unreachable.", $hosts
    echo "Check your internet connection. (or are you using proxy?)"
    nearhost=$default_reposerver
  fi
  reposerver=$nearhost
}

#---------------------------------------
# リポジトリサーバ
#---------------------------------------
create_srclist () {
  codename=`sed -n /DISTRIB_CODENAME=/p /etc/lsb-release`
  cnames=`echo "$codename" | sed 's/DISTRIB_CODENAME=//'`
  for c in $cnames; do
    if test -f "/etc/apt/sources.list"; then
      res=`grep $c /etc/apt/sources.list`
    else
      echo $msg1
      exit
    fi
    if test ! "x$res" = "x" ; then
      code_name=$c
    fi
  done
  if test ! "x$code_name" = "x"; then
    echo $msg2 $code_name
  else
    echo $msg3
    exit
  fi
  openrtm_repo="deb http://$reposerver/pub/Linux/ubuntu/ $code_name main"
}

#---------------------------------------
# ソースリスト更新関数の定義
#---------------------------------------
update_source_list () {
  rtmsite=`apt-cache policy | grep "http://$reposerver"`
  if test "x$rtmsite" = "x" ; then
    echo $msg4
    echo $msg5
    echo "  " $openrtm_repo
    read -p "$msg6" kick_shell

    if test "x$kick_shell" = "xn" ; then
      echo $msg7
      exit 0
    else
      echo $openrtm_repo >> /etc/apt/sources.list
    fi
  fi
  # 公開鍵登録
  wget -O- --secure-protocol=TLSv1_2 --no-check-certificate https://openrtm.org/pub/openrtm.key | apt-key add -
}

#----------------------------------------
# root かどうかをチェック
#----------------------------------------
check_root () {
  if test ! `id -u` = 0 ; then
    echo ""
    echo $msg8
    echo $msg7
    echo ""
    exit 1
  fi
}

#----------------------------------------
# パッケージインストール関数
#----------------------------------------
install_packages () {
#    echo $*
#    exit 0
  for p in $*; do
    echo $msg9 $p
    echo $install_pkgs | grep -x $p > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      tmp_pkg="$install_pkgs $p"
      install_pkgs=$tmp_pkg
    fi

    if test "x$FORCE_YES" = "xtrue" ; then
      apt-get install --assume-yes --allow-unauthenticated $p
    else
      apt-get install $p
    fi
    if [ $? -ne 0 ]; then
      echo $msg7
      exit
    fi
    echo $msg10
    echo ""
  done
}

#------------------------------------------------------------
# リストを逆順にする
#------------------------------------------------------------
reverse () {
  for i in $*; do
    echo $i
  done | sed '1!G;h;$!d'
}

#----------------------------------------
# パッケージをアンインストールする
#----------------------------------------
uninstall_packages () {
  for p in $*; do
    echo $msg11 $p
    echo $uninstall_pkgs | grep -x $p > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      tmp_pkg="$uninstall_pkgs $p"
      uninstall_pkgs=$tmp_pkg
    fi
    apt-get --purge remove $p
    if test "$?" != 0; then
      apt-get purge $p
    fi
    echo $msg10
    echo ""
  done
}

#---------------------------------------
# set_package_content
#---------------------------------------
set_package_content()
{
#--------------------------------------- C++
runtime_pkgs="$omni_runtime $openrtm_runtime"
u_runtime_pkgs=$runtime_pkgs

src_pkgs="$cxx_devel $cmake_tools $deb_pkg $base_tools $omni_runtime $omni_devel"
u_src_pkgs="$omni_runtime $omni_devel"

dev_pkgs="$runtime_pkgs $src_pkgs $openrtm_devel"
u_dev_pkgs="$u_runtime_pkgs $omni_devel $openrtm_devel"

core_pkgs="$src_pkgs $autotools $build_tools $pkg_tools"
u_core_pkgs="$u_src_pkgs"

#--------------------------------------- Python
python_runtime_pkgs="$omni_runtime $python_runtime $openrtm_py_runtime"
u_python_runtime_pkgs="$omni_runtime $openrtm_py_runtime"

python_dev_pkgs="$python_runtime_pkgs $python_devel $openrtm_py_devel"
u_python_dev_pkgs="$u_python_runtime_pkgs $omnipy $openrtm_py_devel"

python_core_pkgs="$omni_runtime $python_runtime $python_devel $build_tools $pkg_tools"
u_python_core_pkgs="$omni_runtime $omnipy"

#--------------------------------------- Java
java_runtime_pkgs="$omni_runtime $openrtm_j_runtime"
u_java_runtime_pkgs="$omni_runtime $openrtm_j_runtime"

java_dev_pkgs="$java_runtime_pkgs $cmake_tools $base_tools $openrtm_j_devel"
u_java_dev_pkgs="$omni_runtime $openrtm_j_runtime $openrtm_j_devel"

java_core_pkgs="$omni_runtime $cmake_tools $base_tools $build_tools $java_build $pkg_tools"
u_java_core_pkgs="$omni_runtime"
}

#---------------------------------------
# install_proc
#---------------------------------------
install_proc()
{
  if test "x$arg_cxx" = "xtrue" ; then
    if test "x$OPT_COREDEVEL" = "xtrue" ; then
      select_opt_c="[c++] install tool_packages for core developer"
      install_packages $core_pkgs
    elif test "x$OPT_SRCPKG" = "xtrue" ; then
      select_opt_c="[c++] install tool_packages for source packages"
      install_packages $src_pkgs
    elif test "x$OPT_RUNTIME" = "xtrue" ; then
      select_opt_c="[c++] install robot component runtime"
      install_packages $runtime_pkgs
    else
      select_opt_c="[c++] install robot component developer"
      install_packages $dev_pkgs
    fi
  fi

  if test "x$arg_python" = "xtrue" ; then
    if test "x$OPT_COREDEVEL" = "xtrue" ; then
      select_opt_p="[python] install tool_packages for core developer"
      install_packages $python_core_pkgs
    elif test "x$OPT_RUNTIME" = "xtrue" ; then
      select_opt_p="[python] install robot component runtime"
      install_packages $python_runtime_pkgs
    else
      select_opt_p="[python] install robot component developer"
      install_packages $python_dev_pkgs
    fi
  fi

  if test "x$arg_java" = "xtrue" ; then
    if test "x$OPT_COREDEVEL" = "xtrue" ; then
      select_opt_j="[java] install tool_packages for core developer"
      install_packages $java_core_pkgs
    elif test "x$OPT_RUNTIME" = "xtrue" ; then
      select_opt_j="[java] install robot component runtime"
      install_packages $java_runtime_pkgs
    else
      select_opt_j="[java] install robot component developer"
      install_packages $java_dev_pkgs
    fi
  fi

  if test "x$arg_openrtp" = "xtrue" ; then
    select_opt_rtp="[openrtp] install"
    install_packages $openrtp_pkgs
  fi

  if test "x$arg_rtshell" = "xtrue" ; then
    select_opt_shl="[rtshell] install"
    install_packages python3-pip
    rtshell_ret=`pip3 install rtshell-aist`
  fi
}

#---------------------------------------
# uninstall_proc
#---------------------------------------
uninstall_proc()
{
  if test "x$arg_cxx" = "xtrue" ; then
    if test "x$OPT_COREDEVEL" = "xtrue" ; then
      select_opt_c="[c++] uninstall tool_packages for core developer"
      uninstall_packages `reverse $u_core_pkgs`
    elif test "x$OPT_SRCPKG" = "xtrue" ; then
      select_opt_c="[c++] uninstall tool_packages for source packages"
      uninstall_packages `reverse $u_src_pkgs`
    elif test "x$OPT_RUNTIME" = "xtrue" ; then
      select_opt_c="[c++] uninstall robot component runtime"
      uninstall_packages `reverse $u_runtime_pkgs`
    else
      select_opt_c="[c++] uninstall robot component developer"
      uninstall_packages `reverse $u_dev_pkgs`
    fi
  fi

  if test "x$arg_python" = "xtrue" ; then
    if test "x$OPT_COREDEVEL" = "xtrue" ; then
      select_opt_p="[python] uninstall tool_packages for core developer"
      uninstall_packages `reverse $u_python_core_pkgs`
    elif test "x$OPT_RUNTIME" = "xtrue" ; then
      select_opt_p="[python] uninstall robot component runtime"
      uninstall_packages `reverse $u_python_runtime_pkgs`
    else
      select_opt_p="[python] uninstall robot component developer"
      uninstall_packages `reverse $u_python_dev_pkgs`
    fi
  fi

  if test "x$arg_java" = "xtrue" ; then
    if test "x$OPT_COREDEVEL" = "xtrue" ; then
      select_opt_j="[java] uninstall tool_packages for core developer"
      uninstall_packages `reverse $u_java_core_pkgs`
    elif test "x$OPT_RUNTIME" = "xtrue" ; then
      select_opt_j="[java] uninstall robot component runtime"
      uninstall_packages `reverse $u_java_runtime_pkgs`
    else
      select_opt_j="[java] uninstall robot component developer"
      uninstall_packages `reverse $u_java_dev_pkgs`
    fi
  fi

  if test "x$arg_openrtp" = "xtrue" ; then
    select_opt_rtp="[openrtp] uninstall"
    uninstall_packages $openrtp_pkgs
  fi

  if test "x$arg_rtshell" = "xtrue" ; then
    select_opt_shl="[rtshell] uninstall"
    rtshell_ret=`pip3 uninstall -y rtshell-aist rtctree-aist rtsprofile-aist`
  fi
}

#---------------------------------------
# print_option
#---------------------------------------
print_option()
{
  cat <<EOF

=============================================
 Selected options is ...
=============================================
EOF

  if test ! "x$select_opt_c" = "x" ; then
    echo $select_opt_c
  fi
  if test ! "x$select_opt_p" = "x" ; then
    echo $select_opt_p
  fi
  if test ! "x$select_opt_j" = "x" ; then
    echo $select_opt_j
  fi
  if test ! "x$select_opt_rtp" = "x" ; then
    echo $select_opt_rtp
  fi
  if test ! "x$select_opt_shl" = "x" ; then
    echo $select_opt_shl
  fi
}

#---------------------------------------
# install_result
#---------------------------------------
install_result()
{
  print_option
  cat <<EOF

=============================================
 Install package is ...
=============================================
EOF
  if [ $# -eq 0 ] && test "x$OPT_UNINST" = "xfalse"; then
    echo "There is no installation package."
    return
  fi

  for p in $*; do
    echo $p
  done
  if test "x$arg_rtshell" = "xtrue" && test "x$OPT_UNINST" = "xtrue"; then
    if test "x$rtshell_ret" != "x"; then
      echo "rtshell" 
    fi
  fi
}

#---------------------------------------
# uninstall_result
#---------------------------------------
uninstall_result()
{
  cat <<EOF

=============================================
 Uninstall package is ...
=============================================
EOF
  if [ $# -eq 0 ] && test "x$OPT_UNINST" = "xtrue"; then
    echo "There is no uninstall package."
    return
  fi

  for p in $*; do
    echo $p
  done
  if test "x$arg_rtshell" = "xtrue" && test "x$OPT_UNINST" = "xfalse"; then
    if test "x$rtshell_ret" != "x"; then
      echo "rtshell" 
    fi
  fi
}

#---------------------------------------
# メイン
#---------------------------------------
init_param
get_opt $@

# 最終オプション確認
if test "x$arg_all" = "xfalse" ; then
  if test "x$arg_cxx" = "xfalse" ; then
    if test "x$arg_python" = "xfalse" ; then
      if test "x$arg_java" = "xfalse" ; then
        if test "x$arg_openrtp" = "xfalse" ; then
          if test "x$arg_rtshell" = "xfalse" ; then
            exit
          fi
        fi
      fi
    fi
  fi
fi

check_lang
check_root
check_reposerver
create_srclist
update_source_list
apt-get autoclean
apt-get update

if test "x$arg_all" = "xtrue" &&
   test "x$OPT_OLD_RTM" = "xfalse" ; then
  arg_cxx=true
  arg_python=true
  arg_java=true
  if test "x${ARCH}" = "xaarch64"; then
    arg_openrtp=false
    echo "[WARNING] openrtp is not supported in aarch64 environment."
  else
    arg_openrtp=true
  fi
  arg_rtshell=true

  if test "x$OPT_RUNTIME" != "xtrue" && 
     test "x$OPT_DEVEL" != "xtrue" &&
     test "x$OPT_SRCPKG" != "xtrue" && 
     test "x$OPT_COREDEVEL" != "xtrue" ; then
    # set default option
    OPT_DEVEL=true
  fi
fi

set_package_content

if test "x$OPT_UNINST" = "xtrue" ; then
  install_proc
else
  uninstall_proc
fi

install_result $install_pkgs
uninstall_result $uninstall_pkgs
if test ! "x$err_message" = "x" ; then
  echo $err_message
fi

# install openjdk-8-jdk
apt -y install openjdk-8-jdk
JAVA8=`update-alternatives --list java | grep java-8`
update-alternatives --set java ${JAVA8}

