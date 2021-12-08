# Function to install package R 
options(repos=structure(c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))) 
install.packages("JuniperKernel")
library(JuniperKernel)
installJuniper(useJupyterDefault = TRUE)  # install into default Jupyter kernel location