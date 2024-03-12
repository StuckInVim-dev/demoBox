# demoBox
demoBox is a tool that allows you to quickly and easily provision multiple Docker containers for SSH login.
It's useful for:
- CTFs
- Practically teaching about GNU/Linux
- Testing in multiple environments
## Usage
Follow the steps and run the commands
1.  `git clone https://github.com/StuckInVim-dev/demoBox`
2. `cd demoBox`
3. Place directories with the dockerfiles into the `children` directory (There is already one  `children/demo`)
4. Build the image back in the root of the project `docker build -t demobox-master`
5. Run the container with
```
docker run -d \
    -p 2002:22 \
    --restart=no \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(which docker):/usr/bin/dockerc \
    -v /path/to/children/directory:/mnt/source \
    demobox-master
```
## Requirements
You just need to have docker installed and have your user be in the `docker` group
Since it's written in Bash, it should work on any version of Linux

## How it works
The setup of all the containers is done by the `init.sh` script, it does the following steps every time when ran:
1. When the master container is ran, it builds all the container from the passed in `children` directory (Container that have already been build will be loaded from cashe, because the cashe is stored on the host)
2. Creates a user for each child container (for SSH)
3. Starts the SSH service
When anyone tries to connect to the master container with SSH as a user that was created for the child containers, they interactively start the contains with the same name as the user they logged in as