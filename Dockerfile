FROM debian:bookworm
COPY conf/debian-bookworm.list /etc/apt/sources.list

# dependencias so
RUN apt-get update

#tools
RUN apt-get install -y --fix-missing --no-install-recommends \   
htop vim zip unzip bash-completion wget git bzip2 curl locate less

#for compile gdal
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
cmake build-essential libproj-dev libmariadb-dev postgresql-client libpq-dev default-mysql-client libmariadb-dev-compat

#software-properties-common g++ make \
# openssl autoconf gtk-doc-tools \
#libc-ares-dev libc-ares-dev libpdf-api2-perl \

#for python informix
RUN apt-get install -y --fix-missing --no-install-recommends \   
python3-pip ipython3 python3-pyodbc \
unixodbc-dev libssl-dev

#nose
#swig protobuf-compiler libprotobuf-c-dev protobuf-c-compiler libcurl4 \




#apache

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends apache2
#libapache2-mod-fcgid cgi-mapserver mapserver-bin

#RUN mapserv -v

RUN a2enmod authnz_fcgi
RUN a2enmod cgi
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

#RUN apt-get install -y --fix-missing --no-install-recommends \   
#     libxml2-dev \
#     libxslt1-dev \
#     librsvg2-dev \
#     libmariadb-dev-compat \
#     libpq-dev \
#     libcurl4-gnutls-dev \
#     libexempi-dev \
#     libfcgi-dev \
#     libpsl-dev \
#     libharfbuzz-dev \
#     libexempi-dev \
#     libgif-dev \
#     libfcgi-dev \
#     libjpeg62-turbo-dev \
#     libcairo2-dev \


#for informix
RUN apt-get install -y --fix-missing --no-install-recommends \   
libncurses5
ENV INFORMIXSERVER=test_pri_pam
ENV INFORMIXDIR=/var/informix
ENV CLIENT_LOCALE=en_us.8859-1
ENV DB_LOCALE=en_us.8859-1
ENV ONCONFIG=onconfig
ENV SQLHOSTS=$INFORMIXDIR/etc/sqlhosts
ENV ODBCINI=/etc/odbc.ini
ENV DBDATE=DMY2/
ENV DBCENTURY=C
ENV DBEDIT=vim
ENV PATH=$PATH:/var/informix/bin
ENV LD_LIBRARY_PATH=$INFORMIXDIR/lib:$INFORMIXDIR/lib/esql:$INFORMIXDIR/lib/cli:$INFORMIXDIR/lib/tools:/lib:/lib/x86_64-linux-gnu:

ADD ./conf/informix/csdk.properties /root/csdk.properties
ADD ./conf/informix/installclientsdk /root/installclientsdk
RUN chmod +x /root/installclientsdk
WORKDIR /root
RUN /root/installclientsdk -i silent -f csdk.properties
ADD ./conf/informix/ld.so.conf /etc/ld.so.conf
ADD ./conf/informix/odbc.ini /etc/odbc.ini
ADD ./conf/informix/odbcinst.ini /etc/odbcinst.ini
RUN ldconfig

COPY ./conf/gdal/gdal-3.10.0.tar.gz /opt/gdal-3.10.0.tar.gz
WORKDIR /opt
RUN tar xvf /opt/gdal-3.10.0.tar.gz
RUN mkdir -p /opt/gdal-3.10.0/build
WORKDIR /opt/gdal-3.10.0/build
RUN cmake -DCMAKE_PREFIX_PATH=/var/informix/ -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DPostgreSQL_INCLUDE_DIR=/usr/include/postgresql -DMYSQL_INCLUDE_DIR=/usr/include/mariadb .. > /root/build_config.log
RUN cmake --build . >> /root/build_config.log
RUN cmake --build . --target install >> /root/build_config.log

#RUN ogrinfo --formats | grep IDB

#build mapserver

RUN apt-get install -y --fix-missing --no-install-recommends \
libprotobuf-dev libpcre2-dev libpng-dev libfreetype-dev libxml2-dev libgif-dev \
libprotobuf-c-dev protobuf-c-compiler libcurl4 libfribidi-dev pkg-config \
libharfbuzz-dev libcairo2-dev libfcgi-dev libgeos-dev libpq-dev swig

WORKDIR /root
RUN wget https://download.osgeo.org/mapserver/mapserver-8.4.0-rc1.tar.gz

RUN tar xvf mapserver-8.4.0-rc1.tar.gz

RUN mkdir mapserver-8.4.0-rc1/build

WORKDIR /root/mapserver-8.4.0-rc1/build

RUN cmake -DCMAKE_INSTALL_PREFIX=/opt -DCMAKE_PREFIX_PATH=/usr/local/pgsql/91:/usr/local:/opt \
-DWITH_CLIENT_WFS=ON -DWITH_CLIENT_WMS=ON -DWITH_CURL=ON -DWITH_SOS=ON -DWITH_PHP=OFF \
-DWITH_PERL=OFF -DWITH_RUBY=OFF -DWITH_JAVA=OFF -DWITH_CSHARP=OFF -DWITH_PYTHON=OFF \
-DWITH_SVGCAIRO=OFF -DWITH_ORACLESPATIAL=OFF -DWITH_MSSQL2008=OFF \
../ > /root/configure.out.txt

RUN make

RUN make install

WORKDIR /root

RUN apt-get install -y --fix-missing --no-install-recommends \
libapache2-mod-fcgid

RUN ln -s /opt/bin/mapserv /usr/lib/cgi-bin/mapserv

RUN ln -s /opt/bin/map2img /usr/local/bin/map2img

#RUN a2enmod actions fastcgi alias

RUN updatedb

#mapcache

RUN apt-get install -y --fix-missing --no-install-recommends \
apache2-dev

WORKDIR /opt

RUN git clone https://github.com/MapServer/mapcache.git

RUN mkdir -p /opt/mapcache/build

WORKDIR /opt/mapcache/build

RUN cmake ..

RUN make
RUN make install



EXPOSE 80

WORKDIR /root
CMD apachectl -D FOREGROUND
#CMD ["/etc/init.d/apache2" ,"start", "-D",  "FOREGROUND"]