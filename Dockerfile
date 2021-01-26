FROM python:slim as jupyter-base
RUN apt update \
&& pip install jupyterlab

FROM jupyter-base as r-base
RUN apt install -y  apt-transport-https ca-certificates software-properties-common gnupg2 libcurl4-openssl-dev libxml2-dev
RUN add-apt-repository "deb http://cloud.r-project.org/bin/linux/debian buster-cran40/ " \
&& apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF' \
&& apt update \
&& apt install -y r-base r-base-dev
RUN mkdir -p /app/notebooks
WORKDIR /app
COPY . .
RUN Rscript irkernel.r

FROM r-base as data-science
WORKDIR /app
COPY . .
RUN pip install -r requirement.txt
RUN Rscript install_packages.r
RUN mkdir -p /root/.jupyter && mv ./jupyter_server_config.json /root/.jupyter/
EXPOSE 8888
ENTRYPOINT ["/app/start_app.sh"]
