FROM mcr.microsoft.com/vscode/devcontainers/base:debian-10

RUN apt-get update \
   && apt-get -y install --no-install-recommends entr make gnupg vim

RUN apt-get -y install lsb-release wget software-properties-common \
    && wget https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh 10 \
    && rm ./llvm.sh \
    && /bin/ln /usr/bin/clang-10 /usr/bin/clang 

RUN apt-get -y install libedit-dev
