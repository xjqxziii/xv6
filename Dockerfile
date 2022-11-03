
# http://xv6.dgs.zone/
# docker run -d -p 2022:22  --name myxv6 -v ./xv6:/xv6 xv6
FROM ubuntu:20.04
LABEL maintainer="xjqxziii"

# 换源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
    apt clean && \
    apt update

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get install -y git build-essential gdb-multiarch qemu-system-misc gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu 
RUN apt-get remove -y qemu-system-misc
RUN apt-get install -y qemu-system-misc=1:4.2-3ubuntu6

RUN apt-get install -y python

# ssh服务器
# 参考 https://github.com/rastasheep/ubuntu-sshd/blob/ed6fffcaf5a49eccdf821af31c1594e3c3061010/18.04/Dockerfile
RUN apt install -y openssh-server
RUN mkdir /var/run/sshd && \
    mkdir /root/.ssh
# 修改 root 的密码为 qqq123
RUN echo 'root:qqq123' | chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


# 删除 apt update 产生的缓存文件
# 因为 docker 的文件系统是层文件系统，上一个层中缓存有apt-get update的结果，
# 那么下次 Dockerfile 
# 这样 docker 中的 apt 软件源就不是最新的软件列表了，将会带来缓存过期的问题。
# 并且这些缓存将占用不少空间，导致最终生成的image非常庞大，
# 而这些垃圾文件是我们最终的image中无需使用到的东西，我们应当在Docker构建过程中予以删除。
RUN apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
