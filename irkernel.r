# Function to install package R 
options(repos=structure(c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))) 
install.packages("IRkernel")
IRkernel::installspec(user=FALSE, displayname="R4.0")