using Resumable
using Base.Test

# First, kick off the docker container that contains the reference Node
# Resumable.js implementation, so we can interact with it.
container_id = readchomp(`docker run --rm -p 3000:3000/tcp -d staticfloat/resumeablejs_test_server`)
info("Test server running in container $(container_id[1:10])")

# Generate a 5MB+ file that will cause us to upload 5 (and a little more) chunks
bigfile = open("bigfile", "w")
write(bigfile, rand(UInt8, 5*1024*1024 + 1337))

try
    # Upload the big file to the Node.JS server
    Resumable.Client.upload_file("bigfile", "http://localhost:3000/upload")

    # Do it again to ensure that we don't need to upload those pieces again
    Resumable.Client.upload_file("bigfile", "http://localhost:3000/upload")

    # TODO verify the big file uploaded properly
finally
    info("Showing logs for docker test container:")
    run(`docker logs $container_id`)

    info("Killing docker server container:")
    success(`docker kill $container_id`)
end
