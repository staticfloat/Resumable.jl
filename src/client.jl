module Client
using HTTP

# Explicitly use a client whose chunksize is well above our chunk size so that
# we don't accidentally trigger chunked encoding
client = HTTP.Client(chunksize=2*1024*1024)
res = nothing

function upload_chunk(file::IOStream, target::AbstractString,
                      chunk_idx::Integer, chunk_size::Integer)


function upload_file(file_path::AbstractString, target::AbstractString;
                     chunk_size::Integer = 1*1024*1024,
                     mime_type::MIME = MIME(""))
    global client, res

    filename = basename(file_path)
    total_size = filesize(file_path)
    num_chunks = ceil(Int,total_size/chunk_size)

    f = open(file_path, "r")

    for chunk_idx = 1:num_chunks
        params = Dict(
            "resumableChunkNumber" => chunk_idx,
            "resumableChunkSize" => chunk_size,
            "resumableCurrentChunkSize" => chunk_size,
            "resumableTotalSize" => total_size,
            "resumableType" => string(mime_type),
            "resumableIdentifier" => "$(total_size)-$(filename)",
            "resumableFileName" => filename,
            "resumableRelativePath" => filename,
            "resumableTotalChunks" => num_chunks,
        )

        # Check each chunk before uploading the full chunk
        uri = HTTP.URI(target; query=params)
        res = HTTP.get(client, uri)
        if res.status != 200
            # That chunk is not there yet, let's post it up.
            seek(f, (chunk_idx - 1)*chunk_size)
            data = read(f, chunk_size)
            params["file"] = IOBuffer(data)

            println("Uploading chunk $chunk_idx...")
            res = HTTP.post(client, uri; body=params)
            if res.status != 200
                error("Upload failed with HTTP code $(res.status)")
            end
        end
    end
end

end #module client
