# Windows/Steam games on Linux!

Play Windows/Steam games on Linux using Steam Proton to do so, and confined inside a Docker container.
Bind X11's socket for the windows to appear and ear the sound from PulseAudio.

## Prerequisites

### Docker

Be sure to have Docker installed thanks to the detailed explanations given on the [Docker official site](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/).

### PulseAudio

For the sound to work, you need the PulseAudio server.
You can check if it's installed and configured by launching a sample sound and looking for a pulseaudio process.
```
aplay /usr/share/sounds/alsa/Front_Center.wav && ps -A | grep pulseaudio
```

### A supported GPU
Currently, Nvidia cards and Intel Integrated chipsets have been tested and should work out of the box whereas AMD may require some additional work (tweaking in [builder.sh](./builder.sh)). Let me know about your experimentations!

## Installation and first launch
Clone this repository to get the [Dockerfile](./Dockerfile) and the helper scripts to build and launch a corresponding container.
```
git clone https://github.com/webanck/docker-steam-proton.git
cd docker-steam-proton
./builder.sh
./launcher.sh
```
Then you should be inside the container as the `proton` user. The last step is to launch Steam for the first time to let it update itself. With the provided alias, launching steam reduces to `steam`.
Now, be warned that it's easier to close Steam from its contextual menu rather than closing its window: if you close its window, you need to kill it manually with `pkill -9 steam`.

## Subsequent uses and data flow
You can leave the container typing `exit` or using the keys `Ctrl+D`.
Your data will remain in the container while you don't delete it, and you can restart it easily with the former launcher script: [`./launcher.sh`](launcher.sh).
You might want to copy some files into the `shared_directory` to transfer files between host and container filesystems which is created by the launcher script and mounted in the home of the proton user.

## Motivation
Have you tried to install Steam on Ubuntu recently?
For me, it has become cumbersome (it doesn't work out of the box anymore) and it messes with other packages such as GPU drivers.
This Docker container is a proposition to simplify this process.
