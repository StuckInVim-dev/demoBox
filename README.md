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
4. Back in the root of the project, run `bash init.sh` or `./init.sh`
Here are the flags use can use with init.sh
```
-i	        Launch master container interactively
-p [PORT]   Serve SSH on different port then 2002
-r	        Run container with restart=unless_stopped
-d	        Delete running master container
```

## Requirements
You just need to have docker installed and have your user be in the `docker` group
Since it's written in Bash, it should work on any version of Linux
## How it works
The setup of all the containers is done by the `init.sh` script, it does the following steps every time when ran:
1. Builds all the images from the dockerfiles in `children/*/Dockerfile`  
2. Builds the master image and copies all the images built in the previous step into it
3. Runs the master container

The `setup` script runs inside the `master` container

4. Installs docker (This step will be moved into the dockerfile in future releases )
5. Loads the images into docker
6. Creates a user for each child container (for SSH)
7. Starts the SSH service
When anyone tries to connect to the master container with SSH as a user that was created for the child containers, they interactively start the contains with the same name as the user they logged in as