# jupyter-lab-docker
For data science, jupyter notebook is quite convenient, while the installation is still time consuming and sometime complicated. Even with Anaconda, you are not fully at free. For example, latest R 4.0 is not supported directly by Anaconda yet.

With Docker technology, we make it ready-to-go application image. You can pull the this image, mount your local notebook folder to run it.

## Step by Step installation.

1. Install Docker Desktop. https://www.docker.com/products/docker-desktop

2. goto a commandline window/terminal,
```sh
docker pull data4learning/jupyterlab
```
3. load the image to container,
```sh
docker run -d -p 8888:8888 jupyterlab
```
4. with a browser, open http://localhost:8888/, with initial password **jupyter**. You are there!

5. Alternatively, if you are going to mount local folder to the image, for example, **D:\documents\mynotebook**
```sh
docker run -d -p 8888:8888 -v /D/documents/mynotebook:/app/notebooks/mynotebook --name=jupyterlab data4learning/jupyterlab
```

## Local Build guide

### For outside of China
```sh
docker build . -t jupytlab:latest
```

### 中国大陆构建

```sh
docker build -f Dockerfile.cn . -t jupyterlab:latest
```
使用阿里/腾讯和清华的镜像网站，速度会快很多。