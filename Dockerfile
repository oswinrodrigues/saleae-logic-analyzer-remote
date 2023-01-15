FROM ubuntu:14.04

# geometry => resolution
ENV GEOMETRY 1300x800

ENV USER logic
ENV DISPLAY :1
RUN apt-get update -y

RUN apt-get install -y --no-install-recommends \
	xfonts-75dpi \
	xfonts-100dpi \
	autocutsel \
	ubuntu-wallpapers \
	xli \
	xfonts-base \
	blackbox \
	xterm

# tigervnc dependencies
RUN apt-get install -y libgnutls28 libpixman-1-0 libtasn1-3-bin libglu1-mesa libxcursor1 libxtst6 xauth x11-utils libxinerama1 x11-xkb-utils

# logic dependencies
RUN apt-get -y install libglib2.0-0 pciutils libnss3 libgtk-3-0 libasound2 libgbm1 libfuse2

WORKDIR /packages

COPY packages/tigervncserver_1.5.90-3ubuntu1_amd64.deb ./
RUN dpkg -i tigervncserver_1.5.90-3ubuntu1_amd64.deb

# install logic
RUN mkdir /home/logic && mkdir /home/logic/Logic
COPY packages/Logic-2.4.4-master.AppImage /home/logic/Logic
RUN chmod +x /home/logic/Logic/Logic-2.4.4-master.AppImage

WORKDIR /home/logic

# cleaing up
RUN rm -rf /packages
RUN apt-get autoclean -y

RUN adduser logic
RUN chown -R logic:logic /home/logic

# configure vnc and blackbox wm
COPY password.txt /home/logic/
COPY config/blackboxrc /home/logic/.blackboxrc
COPY config/startWM.sh /home/logic/
COPY config/start.sh /home/logic/
COPY config/blackbox-menu /etc/X11/blackbox/

USER logic
RUN cat /home/logic/password.txt /home/logic/password.txt | vncpasswd

USER root
RUN rm /home/logic/password.txt

VOLUME /home/logic
EXPOSE 5901

USER root
CMD /home/logic/start.sh
