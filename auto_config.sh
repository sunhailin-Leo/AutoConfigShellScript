#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    auto_config.sh
# Revision:    1.2
# Date:        2019/09/05
# UpdateTime:  2019/10/11
# Author:      sunhailin-Leo
# Email:       379978424@qq.com
# Website:     https://github.com/sunhailin-Leo
# Description: Automatically compile and config ffmpeg, Python 3.7.2(default),
#              PyAV, opencv-python, Keras, Tensorflow(CPU Mode) environment.
# -------------------------------------------------------------------------------
# Copyright (c) [2019] sunhailin-Leo
# auto_config.sh is licensed under the Mulan PSL v1.
# You can use this software according to the terms and conditions of the Mulan PSL v1.
# You may obtain a copy of Mulan PSL v1 at:
#     http://license.coscl.org.cn/MulanPSL
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
# PURPOSE.
# See the Mulan PSL v1 for more details.
# -------------------------------------------------------------------------------
# Version 1.2
#   Fix a fatal error with install python and public dependency
#   Add a new command about help doc (--h or -help)
#   Ps: CentOS 7.4, 7.5 can use this shell script.
# Version 1.1
#   Fix a fatal error with environment config.
#   Use ~/.bashrc instead of ~/.bash_profile in docker image.
# Version 1.0
#   Finish shell script test and run.

# Dependency Version List
CMAKE_VERSION="3.13.2"
ZLIB_VERSION="1.2.11"
Python_Version="3.7.2"
YASM_VERSION="1.3.0"
NASM_VERSION="2.13.01"
LIB_X265_VERSION="3.1.2"
PKG_CONFIG_VERSION="0.29"
FREETYPE_VERSION="2.10.1"
FRIBIDI_VERSION="1.0.4"
GPERF_VERSION="3.1"
FONTCONFIG_VERSION="2.13.92"
LIBASS_VERSION="0.14.0"
LIBMP3LAME_VERSION="3.100"
FFMPEG_VERSION="4.1"
PYAV_VERSION="6.2.0"

# Dependency Download URL List
CMAKE_DOWNLOAD_URL="https://cmake.org/files/v3.13/cmake-${CMAKE_VERSION}.tar.gz"
ZLIB_DOWNLOAD_URL="https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz"
PYTHON_DOWNLOAD_URL="https://www.python.org/ftp/python/${Python_Version}/Python-${Python_Version}.tar.xz"
YASM_DOWNLOAD_URL="http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz"
NASM_DOWNLOAD_URL="http://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.xz"
LIB_X264_DOWNLOAD_URL="git://git.videolan.org/x264.git"
LIB_X265_DOWNLOAD_URL="https://bitbucket.org/multicoreware/x265/downloads/x265_${LIB_X265_VERSION}.tar.gz"
PKG_CONFIG_DOWNLOAD_URL="https://pkg-config.freedesktop.org/releases/pkg-config-${PKG_CONFIG_VERSION}.tar.gz"
FREETYPE_DOWNLOAD_URL="https://sourceforge.net/projects/freetype/files/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz"
FRIBIDI_DOWNLOAD_URL="https://github.com/fribidi/fribidi/releases/download/v${FRIBIDI_VERSION}/fribidi-${FRIBIDI_VERSION}.tar.bz2"
GPERF_DOWNLOAD_URL="http://mirrors.ustc.edu.cn/gnu/gperf/gperf-${GPERF_VERSION}.tar.gz"
FONTCONFIG_DOWNLOAD_URL="https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.gz"
LIBASS_DOWNLOAD_URL="https://github.com/libass/libass/releases/download/${LIBASS_VERSION}/libass-${LIBASS_VERSION}.tar.xz"
FDKAAC_DOWNLOAD_URL="https://github.com/mstorsjo/fdk-aac"
LIBMP3LAME_DOWNLOAD_URL="http://downloads.sourceforge.net/project/lame/lame/${LIBMP3LAME_VERSION}/lame-${LIBMP3LAME_VERSION}.tar.gz"
FFMPEG_DOWNLOAD_URL="https://johnvansickle.com/ffmpeg/release-source/ffmpeg-${FFMPEG_VERSION}.tar.xz"
PYAV_DOWNLOAD_URL="https://github.com/mikeboers/PyAV/archive/v${PYAV_VERSION}.tar.gz"

# -------------------------------------------------------------------------------
# Env init
function init_install_path() {
  echo ">>>>>>>>>>>>> Initializing.. >>>>>>>>>>>>>"
  cd /home
  echo ">>>>>>>>>>>>> Initialization complete >>>>>>>>>>>>>"
}

# public dependency
function install_public_dependency() {
  echo ">>>>>>>>>>>>> Installing public dependency >>>>>>>>>>>>>"
  # cmake zlib zlib-devel
  yum install -y autoconf automake gcc gcc-c++ glib2-devel cairo-devel yasm libtool make git zbar pyzbar db4-devel
  yum install -y bzip2 bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel mercurial libxml2-devel
  yum install -y libpcap-devel xz-devel libffi-devel wget pcre pcre-devel crontab mysql-devel harfbuzz harfbuzz-devel gdbm-devel
  yum install -y centos-release-scl devtoolset-7-toolchain
  scl enable devtoolset-7 bash
  echo ">>>>>>>>>>>>> Install public dependency complete >>>>>>>>>>>>>"
}

# update cmake
function update_cmake() {
  echo ">>>>>>>>>>>>> Updating CMake >>>>>>>>>>>>>"
  curl -O -L "${CMAKE_DOWNLOAD_URL}" && tar xzf cmake-${CMAKE_VERSION}.tar.gz && cd cmake-${CMAKE_VERSION}
  ./bootstrap --prefix=/usr/local && make && make install
  ln -s -f /usr/local/bin/ccmake /usr/bin/ && ln -s -f /usr/local/bin/cmake /usr/bin/
  ln -s -f /usr/local/bin/ctest /usr/bin/ && ln -s -f /usr/local/bin/cpack /usr/bin/
  cd /home && rm -rf cmake-${CMAKE_VERSION} && rm -f cmake-${CMAKE_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> Update CMake complete >>>>>>>>>>>>>"
}

# update zlib
function update_zlib() {
  echo ">>>>>>>>>>>>> Updating zlib >>>>>>>>>>>>>"
  wget "${ZLIB_DOWNLOAD_URL}" && tar -zxf zlib-${ZLIB_VERSION}.tar.gz && cd zlib-${ZLIB_VERSION} && ./configure --libdir=/lib64/
  sed -i "s/CFLAGS=-O3 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN/CFLAGS=-O3 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -fPIC/g" Makefile
  make && make install && cd /home && rm -rf zlib-${ZLIB_VERSION} && rm -f zlib-${ZLIB_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> Update zlib complete >>>>>>>>>>>>>"
}

# Python3.7 env
function compile_install_python372() {
  Current_Version=$(python3 -V 2>&1 | awk '{print $2}')
  if [ "${Current_Version}" = "${Python_Version}" ]; then
    echo "Your Python Version is suitable!"
  else
    echo ">>>>>>>>>>>>> Prepare for install Python ${Python_Version} >>>>>>>>>>>>>"
    echo ">>>>>>>>>>>>> Installing Python ${Python_Version} Environment >>>>>>>>>>>>>"
    wget ${PYTHON_DOWNLOAD_URL} && tar -xJf Python-${Python_Version}.tar.xz
    mkdir /usr/local/Python${Python_Version} && cd Python-${Python_Version}
    ./configure --prefix=/usr/local/Python${Python_Version} && make && make install
    ln -s /usr/local/Python${Python_Version}/bin/python3 /usr/local/bin/python3
    ln -s /usr/local/Python${Python_Version}/bin/pip3 /usr/local/bin/pip3
    sed -i '$a export PATH=/usr/local/Python${Python_Version}/bin:$PATH' ~/.bashrc && cd /home
    rm -rf /home/Python-${Python_Version} && rm -f Python-${Python_Version}.tar.xz && python3 -V && pip3 -V
    echo ">>>>>>>>>>>>> Python ${Python_Version} Environment complete >>>>>>>>>>>>>"
  fi
}

function compile_install_yasm() {
  echo ">>>>>>>>>>>>> Compiling yasm >>>>>>>>>>>>>"
  wget ${YASM_DOWNLOAD_URL} && tar -xzf yasm-${YASM_VERSION}.tar.gz
  cd yasm-${YASM_VERSION} && sed -i 's#) ytasm.*#)#' Makefile.in && ./configure && make && make install && cd /home/
  rm -rf yasm-${YASM_VERSION} && rm -f yasm-${YASM_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> yasm compiled >>>>>>>>>>>>>"
}

function compile_install_nasm() {
  echo ">>>>>>>>>>>>> Compiling nasm >>>>>>>>>>>>>"
  wget ${NASM_DOWNLOAD_URL} && tar xJf nasm-${NASM_VERSION}.tar.xz && cd nasm-${NASM_VERSION}
  ./configure && make && make install && cd /home && rm -rf nasm-${NASM_VERSION} rm -f nasm-${NASM_VERSION}.tar.xz
  echo ">>>>>>>>>>>>> nasm compiled >>>>>>>>>>>>>"
}

function compile_install_libx264() {
  echo ">>>>>>>>>>>>> Compiling libx264 >>>>>>>>>>>>>"
  git clone ${LIB_X264_DOWNLOAD_URL} && cd x264 && ./configure --enable-static --enable-shared && make && make install
  cd /home && rm -rf x264
  echo ">>>>>>>>>>>>> libx264 compiled >>>>>>>>>>>>>"
}

function compile_install_libx265() {
  echo ">>>>>>>>>>>>> Compiling libx265 >>>>>>>>>>>>>"
  wget ${LIB_X265_DOWNLOAD_URL} && tar -zxf x265_${LIB_X265_VERSION}.tar.gz && cd x265_${LIB_X265_VERSION}/build/linux && echo "q" | ./make-Makefiles.bash
  make && make install && cd /home && rm -rf x265_${LIB_X265_VERSION} && rm -f x265_${LIB_X265_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> libx265 compiled >>>>>>>>>>>>>"
}

function compile_install_pkgconfig() {
  echo ">>>>>>>>>>>>> Compiling pkg-config >>>>>>>>>>>>>"
  wget ${PKG_CONFIG_DOWNLOAD_URL} && tar -zxf pkg-config-${PKG_CONFIG_VERSION}.tar.gz
  pip3 install docwriter && cd pkg-config-${PKG_CONFIG_VERSION} && ./configure --with-internal-glib && make && make install
  sed -i '$a export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH' ~/.bashrc
  cd /home && rm -rf pkg-config-${PKG_CONFIG_VERSION} && rm -f pkg-config-${PKG_CONFIG_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> pkg-config compiled >>>>>>>>>>>>>"
}

# Compile libass
function compile_install_libass() {
  echo ">>>>>>>>>>>>> Compiling freetype >>>>>>>>>>>>>"
  wget ${FREETYPE_DOWNLOAD_URL} && tar -zxf freetype-${FREETYPE_VERSION}.tar.gz
  cd freetype-${FREETYPE_VERSION} && export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
  ./configure --prefix=/usr/local --disable-static && make && make install
  cd /home && rm -rf freetype-${FREETYPE_VERSION} && rm -f freetype-${FREETYPE_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> freetype compiled >>>>>>>>>>>>>"

  echo ">>>>>>>>>>>>> Compiling fribidi >>>>>>>>>>>>>"
  wget ${FRIBIDI_DOWNLOAD_URL} && tar xf fribidi-${FRIBIDI_VERSION}.tar.bz2 && cd fribidi-${FRIBIDI_VERSION}
  ./configure --prefix=/usr/local/ --enable-shared && make && make install && cd /home
  rm -rf fribidi-${FRIBIDI_VERSION} && rm -f fribidi-${FRIBIDI_VERSION}.tar.bz2
  echo ">>>>>>>>>>>>> fribidi compiled >>>>>>>>>>>>>"

  echo ">>>>>>>>>>>>> Compiling gperf >>>>>>>>>>>>>"
  wget ${GPERF_DOWNLOAD_URL} && tar -zxf gperf-${GPERF_VERSION}.tar.gz
  cd gperf-${GPERF_VERSION} && ./configure && make && make install && cd /home && rm -rf gperf-${GPERF_VERSION}
  rm -f gperf-${GPERF_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> gperf compiled >>>>>>>>>>>>>"

  echo ">>>>>>>>>>>>> Compiling fontconfig >>>>>>>>>>>>>"
  wget ${FONTCONFIG_DOWNLOAD_URL} && tar -zxf fontconfig-${FONTCONFIG_VERSION}.tar.gz
  \cp -rf /usr/local/lib/pkgconfig/* /usr/lib64/pkgconfig/ && cd fontconfig-${FONTCONFIG_VERSION}
  export PKG_CONFIG_PATH=/usr/lib64/pkgconfig && ./configure --prefix=/usr/local/ --enable-shared --enable-libxml2
  make && make install && cd /home && rm -rf fontconfig-${FONTCONFIG_VERSION} && rm -f fontconfig-${FONTCONFIG_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> fontconfig compiled >>>>>>>>>>>>>"

  echo ">>>>>>>>>>>>> Compiling libass >>>>>>>>>>>>>"
  wget ${LIBASS_DOWNLOAD_URL} && tar xf libass-${LIBASS_VERSION}.tar.xz && cd libass-${LIBASS_VERSION}
  export PKG_CONFIG_PATH=/usr/lib64/pkgconfig && ./configure --prefix=/usr/local/ --enable-shared --enable-static
  make && make install && cd /home && rm -rf libass-${LIBASS_VERSION} && rm -f libass-${LIBASS_VERSION}.tar.xz
  echo ">>>>>>>>>>>>> libass compiled >>>>>>>>>>>>>"
}

# Compile fdk-aac
function compile_install_fdkaac() {
  echo ">>>>>>>>>>>>> Compiling fdk-aac >>>>>>>>>>>>>"
  git clone --depth 1 ${FDKAAC_DOWNLOAD_URL} && cd fdk-aac && autoreconf -fiv
  ./configure --enable-shared --enable-static && make && make install && cd /home && rm -rf fdk-aac
  echo ">>>>>>>>>>>>> fdk-aac compiled >>>>>>>>>>>>>"
}

# Compile libmp3lame
function compile_install_libmp3lame() {
  echo ">>>>>>>>>>>>> Compiling libmp3lame >>>>>>>>>>>>>"
  curl -O -L ${LIBMP3LAME_DOWNLOAD_URL} && tar zxf lame-${LIBMP3LAME_VERSION}.tar.gz && cd lame-${LIBMP3LAME_VERSION}
  ./configure --enable-static --enable-shared --enable-nasm && make && make install && cd /home
  rm -rf lame-${LIBMP3LAME_VERSION} && rm -f lame-${LIBMP3LAME_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> libmp3lame compiled >>>>>>>>>>>>>"
}

# Compile ffmpeg
function compile_install_ffmpeg() {
  echo ">>>>>>>>>>>>> Compiling ffmpeg >>>>>>>>>>>>>"
  \cp -rf /usr/local/lib/pkgconfig/* /usr/lib64/pkgconfig/ && mkdir /usr/local/ffmpeg
  wget ${FFMPEG_DOWNLOAD_URL} && tar xJf ffmpeg-${FFMPEG_VERSION}.tar.xz -C /usr/local/ffmpeg/
  cd /usr/local/ffmpeg/ffmpeg-${FFMPEG_VERSION} && export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
  # ./configure --enable-shared --enable-gpl --enable-pthreads --enable-nonfree --enable-libfdk_aac --enable-libmp3lame --enable-fontconfig --enable-libfreetype --enable-libass --enable-libx264 --enable-libx265 --prefix=/usr/local/ffmpeg/ffmpeg-4.1
  ./configure --prefix=/usr/local/ffmpeg/ffmpeg-4.1 --pkg-config-flags="--static" --extra-cflags=-I"/usr/local/include" --extra-ldflags=-L"/usr/local/lib" --extra-libs=-lpthread --extra-libs=-lm --enable-shared --enable-gpl --enable-pthreads --enable-libfdk_aac --enable-libfreetype --enable-libmp3lame --enable-fontconfig --enable-libass --enable-libx264 --enable-libx265 --enable-nonfree
  make && make install && echo "/usr/local/ffmpeg/ffmpeg-${FFMPEG_VERSION}/lib/" >>/etc/ld.so.conf && ldconfig
  sed -i '$a export PATH=$PATH:/usr/local/ffmpeg/ffmpeg-'${FFMPEG_VERSION}'/bin' ~/.bashrc
  sed -i '$a export PKG_CONFIG_PATH=/usr/lib64/pkgconfig:$PKG_CONFIG_PATH' ~/.bashrc
  sed -i '$a export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' ~/.bashrc
  source ~/.bashrc && cd /home && rm -f ffmpeg-${FFMPEG_VERSION}.tar.xz
  echo ">>>>>>>>>>>>> ffmpeg compiled >>>>>>>>>>>>>"
}

# Compile PyAV
function compile_install_PyAV() {
  echo ">>>>>>>>>>>>> Compiling PyAV >>>>>>>>>>>>>"
  wget ${PYAV_DOWNLOAD_URL} && tar -zxf v${PYAV_VERSION}.tar.gz && cd PyAV-${PYAV_VERSION}
  pip3 install Cython && export PKG_CONFIG_PATH=/usr/local/ffmpeg/ffmpeg-${FFMPEG_VERSION}/lib/pkgconfig/
  python3 setup.py build --ffmpeg-dir=/usr/local/ffmpeg/ffmpeg-${FFMPEG_VERSION} && python3 setup.py install
  cd /home && rm -rf PyAV-${PYAV_VERSION} && rm -f v${PYAV_VERSION}.tar.gz
  echo ">>>>>>>>>>>>> PyAV Compiled >>>>>>>>>>>>>"
}

# Configure libstdc++
function configure_libstdc() {
  echo ">>>>>>>>>>>>> Configuring libstdc++.so.6.0.24 >>>>>>>>>>>>>"
  cp libstdc++.so.6.0.24 /lib64/ && ln -snf /lib64/libstdc++.so.6.0.24 /lib64/libstdc++.so.63
  echo ">>>>>>>>>>>>> Configure libstdc++.so.6.0.24 complete >>>>>>>>>>>>>"
}

# Configure Glibc
function compile_update_glibc() {
  echo ">>>>>>>>>>>>> Compiling and Updating glibc >>>>>>>>>>>>>"
  wget "https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/glibc-2.23.tar.gz" && tar -zxf glibc-2.23.tar.gz
  mkdir glibc-build && cd glibc-build && export LD_LIBRARY_PATH=
  ../glibc-2.23/configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
  make && make install
  if [ "$?" = "0" ];then
    unlink /lib64/libm.so.6 && ln -s /lib64/libm-2.23.so /lib64/libm.so.6 && make install
  else
    echo ">>>>>>>>>>>>> glibc builds and upgrades without replacing the system's 64-bit lib package >>>>>>>>>>>>>"
  fi
  cd /home && rm -rf glibc-build && rm -rf glibc-2.23 && rm -f glibc-2.23.tar.gz
  echo ">>>>>>>>>>>>> glibc compiled and upgraded >>>>>>>>>>>>>"
}

# Configure Keras / Tensorflow
function configure_keras_tensorflow() {
  echo ">>>>>>>>>>>>> Configuring Keras / Tensorflow system environment >>>>>>>>>>>>>"
  configure_libstdc
  compile_update_glibc
  echo ">>>>>>>>>>>>> Keras / Tensorflow system environment already configured >>>>>>>>>>>>>"
}

# Configure OpenCV
function configure_opencv() {
  echo ">>>>>>>>>>>>> Configuring OpenCV system environment >>>>>>>>>>>>>"
  yum -y install libSM-1.2.2-2.el7.x86_64 --setopt=protected_multilib=false
  yum -y install libXext.x86_64 && yum -y install libXrender.x86_64
  echo ">>>>>>>>>>>>> OpenCV system environment already configured >>>>>>>>>>>>>"
}
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
# Init module
function init_module() {
  init_install_path
  install_public_dependency
}

# Update lib module
function update_lib_module() {
  update_cmake
  update_zlib
}

# install_ffmpeg_lib
function install_ffmpeg_lib() {
  compile_install_nasm
  compile_install_yasm
  compile_install_libx264
  compile_install_libx265
  compile_install_pkgconfig
  compile_install_libass
  compile_install_fdkaac
  compile_install_libmp3lame
  compile_install_ffmpeg
  compile_install_PyAV
}

# install_all
function install_all() {
  init_module
  update_lib_module
  compile_install_python372
  install_ffmpeg_lib
  configure_keras_tensorflow
  configure_opencv
}

# install_at_docker_env
function install_at_docker_env() {
  init_module
  update_lib_module
  install_ffmpeg_lib
}

# print help doc
function help_function() {
  echo -e "The current script is suitable for installing multiple and all dependencies, as follows"
  echo -e "1、Fully install: \n    example: ${BASH_SOURCE[0]} install"
  echo -e "2、Install single dependency(such as python): \n    example: ${BASH_SOURCE[0]} install python"
  echo -e "3、Install in docker environment: \n    example: ${BASH_SOURCE[0]} install docker-env"
  echo -e "Current Scipt support library and dependencies: (Installation as shown in 2, enter the complete keyword)"
  echo -e "    cmake      --   cmake ${CMAKE_VERSION}"
  echo -e "    zlib       --   zlib  ${ZLIB_VERSION}"
  echo -e "    python     --   Python ${Python_Version}"
  echo -e "    nasm       --   nasm ${NASM_VERSION}"
  echo -e "    yasm       --   yasm ${YASM_VERSION}"
  echo -e "    libx264    --   libx264"
  echo -e "    libx265    --   libx265 ${LIB_X265_VERSION}"
  echo -e "    pkgconfig  --   pkgconfig ${PKG_CONFIG_VERSION}"
  echo -e "    freetype   --   freetype ${FREETYPE_VERSION}"
  echo -e "    fribidi    --   fribidi ${FRIBIDI_VERSION}"
  echo -e "    gperf      --   gperf ${GPERF_VERSION}"
  echo -e "    fontconfig --   fontconfig ${FONTCONFIG_VERSION}"
  echo -e "    libass     --   libass ${LIBASS_VERSION}"
  echo -e "    fdkaac     --   fdkaac"
  echo -e "    libmp3lame --   libmp3lame ${LIBMP3LAME_VERSION}"
  echo -e "    ffmpeg     --   ffmpeg ${FFMPEG_VERSION}"
  echo -e "    PyAV       --   PyAV (Python Library) ${PYAV_VERSION}"
}
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
# Start
case "${1}" in
  install )
    if [ -z "${2}" ]; then
      read -p "Whether to start the installation process[press (y / n), case-insensitive]:" isInstallNow;
      isInstallNow=$(echo ${isInstallNow} | tr '[A-Z]' '[a-z]')
      if [ "${isInstallNow}" = "y" ]; then
        echo ">>>>>>>>>>>>> Ready to start installation and configuration >>>>>>>>>>>>>"
        install_all
        echo ">>>>>>>>>>>>> All software and dependencies are installed >>>>>>>>>>>>>"
      else
        echo ">>>>>>>>>>>>> Exit installation >>>>>>>>>>>>>"
      fi
    else
      case "${2}" in
        python )
          compile_install_python372
          ;;
        nasm )
          compile_install_nasm
          ;;
        yasm )
          compile_install_yasm
          ;;
        libx264 )
          compile_install_libx264
          ;;
        libx265 )
          compile_install_libx265
          ;;
        pkgconfig )
          compile_install_pkgconfig
          ;;
        libass )
          compile_install_libass
          ;;
        fdkaac )
          compile_install_fdkaac
          ;;
        libmp3lame )
          compile_install_libmp3lame
          ;;
        ffmpeg )
          compile_install_ffmpeg
          ;;
        opencv )
          configure_opencv
          ;;
        keras )
          configure_keras_tensorflow
          ;;
        tensorflow )
          configure_keras_tensorflow
          ;;
        tensorflow-gpu )
          echo ">>>>>>>>>>>>> Installation is not available yet, graphics card and CUDA environment are required (not supported yet). >>>>>>>>>>>>>"
          ;;
        docker-env )
          echo ">>>>>>>>>>>>> Currently installed in Docker environment... >>>>>>>>>>>>>"
          install_at_docker_env
          ;;
        * )
          echo ">>>>>>>>>>>>> Command does not exist. Exit the installation >>>>>>>>>>>>>"
          ;;
      esac
    fi
    ;;
  --h )
    help_function
    ;;
  -help )
    help_function
    ;;
	* )
	  echo ">>>>>>>>>>>>> If you need command help, please type after the command --h or -help >>>>>>>>>>>>>"
    echo ">>>>>>>>>>>>> Command does not exist. Exit the installation >>>>>>>>>>>>>"
    ;;
esac