FROM resin/rpi-raspbian

RUN echo "Hello"

RUN apt-get update

RUN apt-get update && \
    apt-get install -y --force-yes build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
                    libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev \
                    python2.7-dev python2.7-tk python2.7-numpy libopencv-dev wget unzip curl libboost-python-dev  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

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
RUN pip install 'numpy==1.10.4'
RUN pip install Cython==0.24

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

RUN pip install numba 
RUN pip install python-logstash psutil

