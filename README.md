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
3. Place directories with the dockerfiles into the `dockerfiles/default_dosh` directory (There is already one in `dockerfiles/default_dosh/demo`)
4. (Optional) If you want to customize the command that starts the container when logging in, make a directory in `dockerfiles/custom_dosh` and add an extra file to it with the name `dosh`. This file will be used as the user's shell.
5. Deploy the container by running `docker compose up --force-recreate --build` 
## Requirements
You just need to have docker installed and have your user be in the `docker` group

If You want to run Docker in Docker (DIND) You will need to have the [sysbox runtime](https://github.com/nestybox/sysbox/releases/) installed on your host machine 


## How it works
The setup of all the containers is done by the `setup` script, it does the following steps every time when ran:
1. When the master container is ran, it builds all the container from the passed in `dockerfiles/default_dosh` directory (Containers that have already been build will be loaded from cache, because the cache is stored on the host)
2. Creates a user for each child container (for SSH)
3. Starts the SSH service.
   
When anyone tries to connect to the master container with SSH as a user that was created for the child containers, they interactively start the container with the same name as the user they logged in as.