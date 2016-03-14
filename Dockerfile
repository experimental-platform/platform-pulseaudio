FROM experimentalplatform/ubuntu
MAINTAINER Kamil Domański <kamil@domanski.co>

RUN apt-get update && apt-get install -y \
	alsa-utils \
	libasound2 \
	libasound2-plugins \
	pulseaudio \
	pulseaudio-utils \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

ENV HOME /home/pulseaudio
# IMPORTANT: const uid 35234 needs to be the owner of host-mounted socket directory
RUN useradd --create-home --home-dir $HOME pulseaudio -u 35234 \
	&& usermod -aG audio,pulse,pulse-access pulseaudio \
	&& mkdir -p $HOME/socket-directory \
	&& ln -s $HOME/socket-directory /var/run/pulse \
	&& chown -R pulseaudio:pulseaudio $HOME

WORKDIR $HOME
USER pulseaudio

COPY default.pa /etc/pulse/default.pa
COPY client.conf /etc/pulse/client.conf
COPY daemon.conf /etc/pulse/daemon.conf

ENV TERM=xterm

ENTRYPOINT ["dumb-init", "pulseaudio" ]
CMD [ "--log-level=3" ]
