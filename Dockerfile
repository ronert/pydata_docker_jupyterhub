FROM jupyter/jupyterhub

MAINTAINER Ronert Obst <ronert.obst@gmail.com>

RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget libsm6 libxrender1 libfontconfig1 libzmq3-dev python-zmq

# Install anaconda
RUN wget --quiet https://repo.continuum.io/archive/Anaconda3-2.3.0-Linux-x86_64.sh && \
    bash Anaconda3-2.3.0-Linux-x86_64.sh -b -p /opt/anaconda && \
    rm Anaconda3-2.3.0-Linux-x86_64.sh
ENV PATH /opt/anaconda/bin:$PATH
RUN chmod -R a+rx /opt/anaconda

# Install PyData modules and IPython dependencies
RUN conda update --quiet --yes conda && \
    conda update --quiet --yes anaconda && \
    conda install --quiet --yes seaborn pyzmq

# Set up IPython kernel
RUN pip3 install file:///srv/jupyterhub && \
    rm -rf /usr/local/share/jupyter/kernels/* && \
    python -m IPython kernelspec install-self

# Set up legacy Python environment
ENV PY2PATH /opt/anaconda/envs/python2/bin
RUN conda create --yes -n python2 python=2 anaconda ipython pyzmq && \
    $PY2PATH/python $PY2PATH/ipython kernelspec install-self

# Install R
RUN apt-get install -y r-base r-base-dev
RUN R --quiet --no-save -e "install.packages(c('rzmq','repr','IRkernel','IRdisplay'), repos = c('http://irkernel.github.io/', 'http://cran.rstudio.com/'), type = 'source'); library(IRkernel); IRkernel::installspec(user = FALSE)"

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN conda clean -y -t

# Test
RUN python -c "import numpy, scipy, pandas, matplotlib, matplotlib.pyplot, sklearn, seaborn, statsmodels"
