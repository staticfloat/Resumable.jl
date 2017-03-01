using Resumable
using Base.Test

# First, kick off the docker container that contains the reference Node
# Resumable.js implementation, so we can interact with it.
container_id = readchomp(`docker run -p 3000:3000/tcp -d staticfloat/resumeablejs_test_server`)
println("Test server running in container $(container_id[1:10])")

sleep(10)


success(`docker kill $container_id`)
