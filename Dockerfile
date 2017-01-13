FROM resin/rpi-raspbian

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-scipy \
        libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
        libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev \
        python2.7-dev python2.7-tk python2.7-numpy libopencv-dev wget unzip curl libboost && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# FIXME: clone a specific git tag and use ARG instead of ENV once DockerHub supports this.
ENV CLONE_TAG=master

RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/BVLC/caffe.git . && \
    for req in $(cat python/requirements.txt) pydot; do pip install $req; done && \
    mkdir build && cd build && \
    cmake -DCPU_ONLY=1 .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig
WORKDIR /

RUN cd \
	&& wget https://github.com/Itseez/opencv/archive/3.1.0.zip \
	&& unzip 3.1.0.zip \
	&& cd opencv-3.1.0 \
	&& mkdir build \
	&& cd build \
	&& cmake .. \
	&& make -j3 \
	&& make install \
	&& cd \
	&& rm 3.1.0.zip \
	&& rm -rf opencv-3.1.0

RUN cd ~ && \
    mkdir -p dlib-tmp && \
    cd dlib-tmp && \
    curl -L \
         https://github.com/davisking/dlib/archive/v19.0.tar.gz \
         -o dlib.tar.bz2 && \
    tar xf dlib.tar.bz2 && \
    cd dlib-19.0 && \
    python setup.py install --yes USE_AVX_INSTRUCTIONS && \
    rm -rf ~/dlib-tmp

RUN sudo apt-get remove -y --force-yes python-numpy
RUN pip install 'numpy==1.10.4' Cython==0.24

RUN cd ~ && \
    mkdir -p cypico-tmp && \
    cd cypico-tmp && \
    wget https://github.com/menpo/cypico/archive/master.zip \
    && unzip master.zip \
    && cd cypico-master/cypico/ \
    && wget https://github.com/menpo/pico/archive/a7a312bcea4035e864f18235b8a8e530d50ac658.zip \
    && unzip a7a312bcea4035e864f18235b8a8e530d50ac658.zip \
    &&  rm -rf pico \
    &&  mv pico-a7a312bcea4035e864f18235b8a8e530d50ac658 pico \
    && cd .. \
    && python setup.py install \
    && rm -rf cypico-tmp

RUN wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
RUN apt-get update && apt-get -y install software-properties-common
RUN add-apt-repository "deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty main"
RUN apt-get install -y llvm-3.8
RUN dpkg --get-selections|grep llvm
RUN cd /usr/bin && ln -s llvm-config-3.8  llvm-config
RUN cd ~ && \
    git clone https://github.com/numba/llvmlite && \
    cd llvmlite && \
    python setup.py install && \
    cd .. && \
    rm -rf llvmlite

RUN pip install numba python-logstash psutil 
