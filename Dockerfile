FROM ubuntu
MAINTAINER Antoine Webanck <antoine.webanck@gmail.com>

# Parameterizing docker build.
ARG PROTON_USER_UID=1001
ARG GPU_TYPE=NVIDIA

# Creating the proton user and setting up dedicated non-root environment: replace 1001 by your user id (id -u) for X sharing.
RUN useradd -u "$PROTON_USER_UID" -d /home/proton -m -s /bin/bash proton
ENV HOME=/home/proton
WORKDIR /home/proton

# Setting up an alias to launch Steam easily.
RUN su proton -c "echo 'alias steam=\"proton /usr/games/steam\"' >> /home/proton/.bashrc"

# Adding the link to the pulseaudio server for the client to find it.
ENV PULSE_SERVER=unix:/run/user/"$PROTON_USER_UID"/pulse/native

#########################START  INSTALLATIONS##########################

# We don't want any interaction from package installation during the docker image building.
ARG DEBIAN_FRONTEND=noninteractive


# We need the 32 bits architecture to allow steam.
RUN dpkg --add-architecture i386 && \
# Updating and upgrading a bit.
	apt-get update && \
#	apt-get upgrade -y && 
# We need software-properties-common to add ppas and wget and apt-transport-https to add repositories and their keys.
	apt-get install -y --no-install-recommends gpg-agent software-properties-common apt-transport-https wget && \
# Adding required ppas: graphics drivers (for Nvidia GPU).
	( [ "$GPU_TYPE" = NVIDIA ] && add-apt-repository ppa:graphics-drivers/ppa && apt-get update || true ) && \
# Installation of graphics driver (Nvidia or Intel chipsets).
	( \
		[ "$GPU_TYPE" = NVIDIA ] && apt-get install -y --no-install-recommends initramfs-tools nvidia-driver-460 || \
		[ "$GPU_TYPE" = INTEL ] && apt-get install -y --no-install-recommends libgl1-mesa-glx libgl1-mesa-dri mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
	) && \
# Installation of pulseaudio support for sound.
	apt-get install -y --no-install-recommends pulseaudio && \
	sed -i "s/; enable-shm = yes/enable-shm = no/g" /etc/pulse/daemon.conf && \
	sed -i "s/; enable-shm = yes/enable-shm = no/g" /etc/pulse/client.conf && \
# Installation of steam.
	apt-get install -y steam && \
# Cleaning up.
	apt-get autoremove -y --purge software-properties-common && \
	apt-get autoremove -y --purge && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#########################END OF INSTALLATIONS##########################

# Launching the shell by default as proton user.
USER proton
CMD /bin/bash
