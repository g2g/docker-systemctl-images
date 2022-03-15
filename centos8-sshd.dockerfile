FROM centos:8.1.1911

LABEL __copyright__="(C) Guido U. Draheim, licensed under the EUPL" \
      __version__="1.6.4521"
ARG PASSWORD=P@ssw0rd.788daa5d938373fe628f1dbe8d0c319c5606c4d3e857eb7
EXPOSE 22

# RUN yum install -y epel-release python3
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
#RUN yum update
RUN yum install -y passwd
RUN yum search sshd
RUN yum install -y openssh-server
RUN rpm -q --list openssh-server
RUN ssh-keygen -A
RUN mkdir /root/.ssh
COPY files/ssh/docker_ed25519.pub /root/.ssh/authorized_keys
RUN chmod -R 0700 /root/.ssh/

COPY files/docker/systemctl3.py /usr/bin/systemctl3.py
COPY files/docker/journalctl3.py /usr/bin/journalctl3.py
RUN sed -i -e "s|/usr/bin/python3|/usr/libexec/platform-python|" /usr/bin/systemctl3.py
RUN cp /usr/bin/systemctl3.py /usr/bin/systemctl
RUN cp /usr/bin/journalctl3.py /usr/bin/journalctl

# > systemctl cat sshd
# Wants=sshd-keygen.target

RUN systemctl enable sshd-keygen.target --force
RUN systemctl enable sshd
RUN rm -vf /run/nologin

#
RUN yum install -y openssh-clients
RUN rpm -q --list openssh-clients
RUN useradd -g nobody testuser
RUN echo $PASSWORD | passwd --stdin testuser
RUN TZ=UTC date -I > /home/testuser/date.txt
CMD /usr/bin/systemctl
ENTRYPOINT /usr/bin/systemctl start sshd && /bin/bash
