FROM python:slim as python-base
RUN apt update \
&& apt install -y  apt-transport-https ca-certificates software-properties-common gnupg2 \
libcurl4-openssl-dev libxml2-dev libpoppler-cpp-dev libssl-dev curl locales git

FROM python-base as jupyter-base
RUN pip install jupyterlab \
&& cd ~ \
&& curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh \
&& bash nodesource_setup.sh \
&& apt install -y nodejs
RUN pip install --upgrade jupyterlab jupyterlab-git \
&& pip install --upgrade jupyterlab-git==0.30.0b1 \
&& jupyter labextension install @techrah/text-shortcuts \
&& jupyter lab build \
&& jupyter labextension enable

FROM jupyter-base as r-base
RUN add-apt-repository "deb http://cloud.r-project.org/bin/linux/debian buster-cran40/ " \
&& apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'
RUN apt update \
&& apt install -y r-base r-base-dev \
&& sed -i 's/^# *\(en_GB.UTF-8\)/\1/' /etc/locale.gen \
&& sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
&& sed -i 's/^# *\(zh_CN.UTF-8\)/\1/' /etc/locale.gen \
&& locale-gen

RUN mkdir -p /app
WORKDIR /app
COPY . .
RUN Rscript irkernel.r

FROM r-base as data-science
WORKDIR /app
COPY . .
RUN pip install -r requirement.txt \
&& Rscript install_packages.r
RUN mkdir -p /root/.jupyter && mv ./jupyter_server_config.json /root/.jupyter/ \
&& rm  *.r *.txt


FROM data-science as ipy-plot-base
# add kite for code completion
RUN apt install wget \
&& bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)" \
&& python -m pip install --upgrade pip \
&& pip install "jupyterlab-kite>=2.0.2" \
# add ipympl for better support of matplotlib
&& pip install ipympl \
# add ipywidgets for interactive 
&& pip pip install ipywidgets


EXPOSE 8888
ENTRYPOINT ["/app/start_app.sh"]
