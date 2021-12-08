################################################################################################
# For own working Data Analysis Practices
# JupyterLab, with Python+R
# most common support libraries 
# facilitating extensions, like git/github/debugger/variable.
# LaTex
# Matplotlib
# Plotly
# 
################################################################################################

#-----------------------------------------------------------------------------------------------
# try multi-stage building to reduce size of image and for debug
# 

# 1. using python:slim as a base 
FROM python:slim as python-base
RUN apt update \
&& apt-get install -y  apt-transport-https ca-certificates software-properties-common gnupg2 \
libcurl4-openssl-dev libxml2-dev libpoppler-cpp-dev libssl-dev curl locales git gcc g++ cmake \
&& python -m pip install --upgrade pip

FROM python-base as jupyter-base

RUN  apt update && \
# 1. install node.js
apt install -y nodejs && \

# 2. install jupyterlab 
pip install jupyterlab jupyterlab-git

FROM jupyter-base as r-env
# 构建R4.0
RUN \
add-apt-repository "deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/ "   && \                
apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
RUN apt update && \
apt install -y r-base r-base-dev  && \
# Uncomment en_US.UTF-8 for inclusion in generation
sed -i 's/^# *\(en_GB.UTF-8\)/\1/' /etc/locale.gen && \
sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
sed -i 's/^# *\(zh_CN.UTF-8\)/\1/' /etc/locale.gen && \
# Generate locale
locale-gen


RUN mkdir -p /app
WORKDIR /app
COPY . .
RUN Rscript irkernel.r && \
mkdir -p /root/.jupyter && mv ./jupyter_server_config.json /root/.jupyter/ 

FROM r-env as data-analysis-env
# install libraries
RUN pip install -r requirement.txt
RUN pip install -r jupyter-lab-extension-pip-requirements.txt
RUN Rscript install_packages_en.r

FROM data-analysis-env as labextension
# install extensions
RUN jupyter labextension install --no-build \
@jupyterlab/debugger \
@jupyterlab/geojson-extension \ 
@jupyterlab/toc \
@jupyter-widgets/jupyterlab-manager jupyter-matplotlib \
jupyterlab-drawio \
@jupyter-widgets/jupyterlab-manager plotlywidget@4.9.0 \
jupyterlab-spreadsheet \
jupyterlab-topbar-extension jupyterlab-system-monitor \
@jupyter-widgets/jupyterlab-manager keplergl-jupyter \
@kiteco/jupyterlab-kite \
@lckr/jupyterlab_variableinspector \
@ryantam626/jupyterlab_code_formatter \
@mflevine/jupyterlab_html \
@techrah/text-shortcuts \
&& RUN jupyter lab build && jupyter labextension enable 

WORKDIR /app
RUN rm *.r *.txt

EXPOSE 8888
ENTRYPOINT ["/app/start_app.sh"]
