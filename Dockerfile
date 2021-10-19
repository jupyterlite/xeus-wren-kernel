FROM emscripten/emsdk:2.0.27


ARG USER_ID
ARG GROUP_ID

# RUN addgroup --gid $GROUP_ID user
# RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user
# USER user

# # RUN apt-get update && \
# #     apt-get install -qqy doxygen git && \
# #     mkdir -p /opt/libvpx/build && \
# #     git clone https://github.com/webmproject/libvpx /opt/libvpx/src



RUN mkdir -p /install
RUN mkdir -p /install/lib




##################################################################
# xtl
##################################################################
RUN mkdir -p /opt/xtl/build && \
    git clone https://github.com/xtensor-stack/xtl.git  /opt/xtl/src
RUN cd  /opt/xtl/src && git checkout tags/0.7.2

RUN cd /opt/xtl/build && \
    emcmake cmake ../src/   -DCMAKE_INSTALL_PREFIX=/install

RUN cd /opt/xtl/build && \
    emmake make -j8 install


##################################################################
# nloman json
##################################################################
RUN mkdir -p /opt/nlohmannjson/build && \
    git clone https://github.com/nlohmann/json.git /opt/nlohmannjson/src
RUN cd /opt/nlohmannjson/src && git checkout tags/v3.9.1

RUN cd /opt/nlohmannjson/build && \
    emcmake cmake ../src/   -DCMAKE_INSTALL_PREFIX=/install -DJSON_BuildTests=OFF

RUN cd /opt/nlohmannjson/build && \
    emmake make -j8 install


##################################################################
# xeus itself
##################################################################
RUN mkdir -p /opt/nlohmannjson/build &&  \
    git clone  https://github.com/jupyter-xeus/xeus.git   /opt/xeus
RUN cd /opt/xeus && git checkout e7e60eee44d00627007e8032a52d12f04b9a3523

RUN cd /install/lib && echo "LS" && ls
RUN cd /install/include && echo "LS" && ls
RUN mkdir -p /xeus-build && cd /xeus-build  && ls &&\
    emcmake cmake  /opt/xeus \
        -DCMAKE_INSTALL_PREFIX=/install \
        -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
        -Dxtl_DIR=/install/share/cmake/xtl \
        -DXEUS_EMSCRIPTEN_WASM_BUILD=ON
RUN cd /xeus-build && \
    emmake make -j4 install




##################################################################
# wren
##################################################################
ADD CMakeLists.txt  .
RUN git clone https://github.com/wren-lang/wren   /opt/wasm_wren
RUN cd /opt/wasm_wren/ && git checkout tags/0.4.0

RUN emcmake cmake -DCMAKE_BUILD_TYPE=Release      \
      -DCMAKE_INSTALL_PREFIX=/install  \
      -DSRC_DIR=/opt/wasm_wren \
      .

RUN emmake make -j2 install



##################################################################
# xeus-wren
##################################################################

ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN mkdir -p /opt/nlomannjson/build &&  \
   git clone -b io https://github.com/DerThorsten/xeus-wren.git  /opt/xeus-wren
RUN cd /opt/xeus-wren/ && git checkout tags/0.3.2

# COPY xeus-wren /opt/xeus-wren

RUN mkdir -p /xeus-wren-build && cd /xeus-wren-build  && ls && \
    emcmake cmake  /opt/xeus-wren \
        -DXEUS_WREN_EMSCRIPTEN_WASM_BUILD=ON \
        -DCMAKE_INSTALL_PREFIX=/install \
        -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
        -Dxtl_DIR=/install/share/cmake/xtl \
        -DWREN_INCLUDE_DIR=/opt/wasm_wren/wren-5.3.4/src \
        -DWREN_LIBRARY=/install/lib/libwren.a \
        -Dxeus_DIR=/install/lib/cmake/xeus 

RUN cd /xeus-wren-build && \
    emmake make -j8 

