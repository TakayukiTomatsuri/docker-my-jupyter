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

#anacondaのインストール。URLは所望のものにせよ
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

#tiniのインストール
RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean



# ++++++++++++

#jupyterの準備
RUN  apt update ; apt install -y nodejs npm
#メモリが4GB、sWAPガ4GBの環境では成功するが、もしかしたら2GB swap1GBの環境だと失敗するかも。webpackがどうとかいわれるはず
RUN  jupyter labextension install -y @jupyterlab/toc
RUN conda install -c conda-forge jupytext -y
RUN jupyter lab build

# +++++++++++++ここは好きにして+++
#pandasで使うパッケージの準備
RUN /opt/conda/bin/conda install -y -c conda-forge category_encoders  
RUN /opt/conda/bin/conda install -y -c conda-forge imbalanced-learn 
RUN /opt/conda/bin/conda install -y -c anaconda joblib  
RUN /opt/conda/bin/conda install -y -c conda-forge tldextract 
RUN /opt/conda/bin/conda install -y -c conda-forge jupyter_contrib_nbextensions
RUN /opt/conda/bin/conda install -y -c conda-forge numexpr 
# +++++++++++++ここは好きにして+++

#ワーキングディレクトリ
RUN mkdir /notes

#PID1のプロセスは特別扱いなので、このようなそれ用のものをエントリポイントにしておくのが無難
ENTRYPOINT [ "/usr/bin/tini", "--" ]
#CMD [ "/bin/bash" ]

#起動時に行うスクリプト
COPY startup.sh /startup.sh
RUN chmod 744 /startup.sh
CMD ["/startup.sh"]


#なぜかこれではアクセスできない
# CMD [ "/bin/bash -c 'jupyter lab --ip=0.0.0.0 --port=49161 --no-browser --allow-root' " ]
# CMD [ "jupyter lab --ip=0.0.0.0 --port=49161 --no-browser --allow-root" ]
