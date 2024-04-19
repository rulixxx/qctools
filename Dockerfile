FROM  ubuntu:22.04 as builder

USER  root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -yq update --fix-missing
RUN apt-get install -yq --no-install-recommends locales
RUN apt-get -y install wget
RUN apt-get -y install zip
RUN apt-get -y install r-base
RUN apt-get -y install libxml2-dev
RUN apt-get -y install libcurl4-openssl-dev
RUN apt-get -y install libssl-dev
RUN apt-get -y install python3-pip

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV R_LIBS $OPT/R-lib
ENV R_LIBS_USER $R_LIBS
ENV LD_LIBRARY_PATH $OPT/lib
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN mkdir -p $OPT/bin
RUN mkdir -p $OPT/share
RUN mkdir -p $R_LIBS
RUN mkdir -p $OPT/lib/python3
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip
RUN unzip fastqc_v0.12.1.zip
RUN mv FastQC $OPT/share/FastQC
RUN ln -s $OPT/share/FastQC/fastqc $OPT/bin/fastqc
RUN wget https://bitbucket.org/kokonech/qualimap/downloads/qualimap_v2.3.zip
RUN unzip qualimap_v2.3.zip
RUN mv qualimap_v2.3 $OPT/share/qualimap 
RUN ln -s $OPT/share/qualimap/qualimap $OPT/bin/qualimap
ADD build/libInstall.R build/
RUN Rscript build/libInstall.R $R_LIBS
RUN pip3 install --target=$OPT/lib/python3 multiqc
RUN ln -s $OPT/lib/python3/bin/* $OPT/bin/
COPY sample_swap.py $OPT/bin

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -yq update --fix-missing
RUN apt-get install -yq --no-install-recommends \
locales \
samtools \
python3 \
perl \
default-jre \
r-base \
libxml2 \
libcurl4 \
python3-distutils \
python3-setuptools \
python3-pandas



RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV R_LIBS $OPT/R-lib
ENV R_LIBS_USER $R_LIBS
ENV LD_LIBRARY_PATH $OPT/lib
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV JAVA_HOME /usr
ENV PYTHONPATH $OPT/lib/python3

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
