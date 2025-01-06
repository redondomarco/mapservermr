FROM debian:bookworm
COPY conf/debian-bookworm.list /etc/apt/sources.list

# dependencias so
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
software-properties-common g++ make \
cmake wget git bzip2 apache2 curl apache2-dev \
build-essential openssl autoconf gtk-doc-tools libc-ares-dev libc-ares-dev libpdf-api2-perl \
python3-pip ipython3 python3-pyodbc \
swig protobuf-compiler libprotobuf-c-dev protobuf-c-compiler libcurl4 \
htop vim zip unzip bash-completion libncurses5  unixodbc-dev  libssl-dev

RUN apt-get install -y --fix-missing --no-install-recommends \
    libxml2-dev \
    libxslt1-dev \
    libfribidi-dev \
    libcairo2-dev \
    librsvg2-dev \
    libmariadb-dev-compat \
    libmariadb-dev \
    libpq-dev \
    libcurl4-gnutls-dev \
    libexempi-dev \
    libfcgi-dev \
    libpsl-dev \
    libharfbuzz-dev \
    libexempi-dev \
    libgif-dev \
    libfcgi-dev \
    libjpeg62-turbo-dev \
    libproj-dev \
    libcairo2-dev \
    libprotobuf-dev 

RUN apt-get install -y libgdal-dev



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
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INFORMIXDIR/lib:$INFORMIXDIR/lib/esql:$INFORMIXDIR/lib/cli:$INFORMIXDIR/lib/tools:/lib:/lib/x86_64-linux-gnu:

#informix

ADD ./conf/informix/csdk.properties /root/csdk.properties
ADD ./conf/informix/installclientsdk /root/installclientsdk
WORKDIR /root
RUN /root/installclientsdk -i silent -f csdk.properties
ADD ./conf/informix/ld.so.conf /etc/ld.so.conf
ADD ./conf/informix/odbc.ini /etc/odbc.ini
ADD ./conf/informix/odbcinst.ini /etc/odbcinst.ini
RUN ldconfig

COPY ./conf/gdal/gdal-3.10.0.tar.gz /opt/gdal-3.10.0.tar.gz

#COPY ./conf/build.sh /opt/build.sh
#RUN /opt/build.sh

WORKDIR /opt
RUN tar xvf /opt/gdal-3.10.0.tar.gz
RUN mkdir -p /opt/gdal-3.10.0/build
WORKDIR /opt/gdal-3.10.0/build
RUN cmake -DCMAKE_PREFIX_PATH=/var/informix/ ..
RUN cmake --build .
RUN cmake --build . --target install

RUN ogrinfo --formats | grep IDB

EXPOSE 80
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD apachectl -D FOREGROUND
#CMD ["/etc/init.d/apache2" ,"start", "-D",  "FOREGROUND"]