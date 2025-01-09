FROM debian:bookworm
COPY conf/debian-bookworm.list /etc/apt/sources.list

# dependencias so
RUN apt-get update

#tools
RUN apt-get install -y --fix-missing --no-install-recommends \   
htop vim zip unzip bash-completion wget git bzip2 curl locate less

#for compile gdal
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
cmake build-essential libproj-dev

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

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
apache2 \
libapache2-mod-fcgid cgi-mapserver mapserver-bin

#RUN mapserv -v

RUN a2enmod authnz_fcgi
RUN a2enmod cgi
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo "SetEnv MapFile1 /root/MapFile1.map" >> /etc/apache2/apache2.conf

#RUN apt-get install -y --fix-missing --no-install-recommends \   
#     libxml2-dev \
#     libxslt1-dev \
#     libfribidi-dev \
#     libcairo2-dev \
#     librsvg2-dev \
#     libmariadb-dev-compat \
#     libmariadb-dev \
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
#     libprotobuf-dev \
#     libgdal-dev

#for informix
RUN apt-get install -y --fix-missing --no-install-recommends \   
libncurses5
ENV INFORMIXSERVER=test_pri
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

#COPY ./conf/gdal/gdal-3.10.0.tar.gz /opt/gdal-3.10.0.tar.gz
#WORKDIR /opt
#RUN tar xvf /opt/gdal-3.10.0.tar.gz
#RUN mkdir -p /opt/gdal-3.10.0/build
#WORKDIR /opt/gdal-3.10.0/build
#RUN cmake -DCMAKE_PREFIX_PATH=/var/informix/ ..
#RUN cmake --build .
#RUN cmake --build . --target install

COPY ./conf/gdal/gdal-3.6.2.tar.gz /opt/gdal-3.6.2.tar.gz
WORKDIR /opt
RUN tar xvf /opt/gdal-3.6.2.tar.gz
RUN mkdir -p /opt/gdal-3.6.2/build
WORKDIR /opt/gdal-3.6.2/build
RUN cmake -DCMAKE_PREFIX_PATH=/var/informix/ .. > build_config.log
RUN cmake --build . >> build_config.log
RUN cmake --build . --target install >> build_config.log

#RUN ogrinfo --formats | grep IDB

RUN updatedb

EXPOSE 80

WORKDIR /root
CMD apachectl -D FOREGROUND
#CMD ["/etc/init.d/apache2" ,"start", "-D",  "FOREGROUND"]