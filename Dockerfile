FROM stackbrew/ubuntu:13.10

# Fake a fuse install
RUN apt-get install libfuse2
RUN cd /tmp ; apt-get download fuse
RUN cd /tmp ; dpkg-deb -x fuse_* .
RUN cd /tmp ; dpkg-deb -e fuse_*
RUN cd /tmp ; rm fuse_*.deb
RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN cd /tmp ; dpkg-deb -b . /fuse.deb
RUN cd /tmp ; dpkg -i /fuse.deb


RUN apt-get -qq update
RUN apt-get install -y python python-pip git openjdk-7-jre-headless openjdk-7-jdk libmemcached-dev python-all-dev libxml2-dev libxslt1-dev zlib1g-dev

RUN wget http://www.apache.si/lucene/solr/4.6.0/solr-4.6.0.tgz -O /tmp/solr.tgz
RUN tar -zxf /tmp/solr.tgz -C /solr --strip-components=1
RUN mkdir /solr_home
RUN cp /solr/example/solr/solr.xml /solr_home/solr.xml

RUN mkdir /solr_home/lib
RUN wget https://bitbucket.org/mavrik/slovene_lemmatizer/downloads/lemmatizer_solr_1.1.jar -O /solr_home/lib/lemmatizer_solr_1.1.jar

RUN git clone https://bitbucket.org/mavrik/news-buddy.git /news-buddy
RUN mkdir /solr_home/news
RUN touch /solr_home/news/core.properties
RUN mkdir /solr_home/news/conf
RUN cp -rv /news-buddy/solr/config/* /solr_home/news/conf/

RUN cd /solr/example; java -Xmx2G -Dsolr.solr.home=/solr_home/ -jar /solr/example/start.jar &

RUN pip install virtualenv
RUN cd /news-buddy/
RUN virtualenv --no-site-packages .
RUN source bin/activate