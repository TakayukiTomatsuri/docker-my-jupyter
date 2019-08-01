FROM ubuntu:bionic

#  $ docker build . -t continuumio/anaconda3:latest -t continuumio/anaconda3:5.3.0
#  $ docker run --rm -it continuumio/anaconda3:latest /bin/bash
#  $ docker push continuumio/anaconda3:latest
#  $ docker push continuumio/anaconda3:5.3.0

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean



# ++++++++++++

ENTRYPOINT [ "/usr/bin/tini", "--" ]
#CMD [ "/bin/bash" ]



# +++++++++++++

#メモリが4GB、sWAPガ4GBの環境では成功するが、もしかしたら2GB swap1GBの環境だと失敗するかも。webpackがどうとかいわれるはず

RUN  apt update ; apt install -y nodejs npm
RUN  jupyter labextension install -y @jupyterlab/toc
RUN conda install -c conda-forge jupytext -y
RUN jupyter lab build




# CMD [ "/bin/bash -c 'jupyter lab --ip=0.0.0.0 --port=49161 --no-browser --allow-root' " ]
# CMD [ "jupyter lab --ip=0.0.0.0 --port=49161 --no-browser --allow-root" ]



RUN mkdir /notes

# 起動時に行うスクリプト
COPY startup.sh /startup.sh
RUN chmod 744 /startup.sh
CMD ["/startup.sh"]

# +++++++++++++
# RUN apt update 
# RUN apt upgrade -y
# RUN apt install  -y nodejs npm

# # jupyterで必要なものインストール
# RUN /opt/conda/bin/conda update --all -y
# RUN /opt/conda/bin/conda update --all -y

# RUN /opt/conda/bin/conda install jupyter -y

# どっち？
# conda install -c conda-forge jupyterlab


# RUN /opt/conda/bin/conda install -c conda-forge jupytext -y
# # RUN /opt/conda/bin/jupyter labextension install -y jupyterlab-jupytext@0.19



# #RUN /opt/conda/bin/conda install -c krinsman jupyterlab-toc # outdated!
# RUN /opt/conda/bin/jupyter labextension install -y @jupyterlab/toc

# RUN /opt/conda/bin/conda update --all -y
# RUN /opt/conda/bin/conda update --all -y

# RUN /opt/conda/bin/jupyter lab build



# RUN mkdir /notes

# # 起動時に行うスクリプト
# COPY startup.sh /startup.sh
# RUN chmod 744 /startup.sh
# CMD ["/startup.sh"]