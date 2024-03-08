#!/bin/bash
set -e
master_image_name="master-virtssh"
master_container_name="master-virtssh"

for dir in $(find "children" -type d); do
    # Skip the root directory
    if [ "$dir" == "children" ]; then
        continue
    fi

    # Change into the child directory
    cd $dir

    # Construct the container name in the format: "childrenchild"
    container_name="virtssh-$(echo "$dir" | tr -d '/')"

    # Build the child image
    docker build -t $container_name .

    # LOG
    echo "@@@Built child image $container_name from $dir successfully"

    # Construct the image path
    image_path="child_images/$container_name"

    # Return back to the root of the project
    cd -

    # Save the child image into the archive
    docker save $container_name > "$image_path.tar"

    # LOG
    echo "@@@Saved child image $container_name successfully"
done

# Build the master image
docker build -t $master_image_name .

# LOG
echo "@@@Built master image $master_image_name successfully"

# If the argument is "r", remove the old master container
if [ "$1" = "r" ]; then
    docker rm -f $master_container_name
    echo "@@@Removed old master container successfully"
else
    echo "@@@Skipping removal of old master container"
fi

# Run the master container
docker run -it \
    -p 2002:22 \
    --name=$master_container_name \
    --restart=unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(which docker):/usr/bin/dockerc \
    $master_image_name

# LOG
echo "@@@Started master container $master_container_name successfully"
