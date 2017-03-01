module Client
using HTTP

client = HTTP.Client()
res = nothing

function upload_file(file_path::AbstractString, target::AbstractString;
                     chunk_size::Integer = 1*1024*1024,
                     mime_type::MIME = MIME(""))
    global client, res

    filename = basename(file_path)[1:end-4]
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
        res = HTTP.get(client, uri; verbose=true)
        if res.status != 200
            # That chunk is not there yet, let's post it up.
            seek(f, chunk_idx*chunk_size - 1)
            data = read(f, chunk_size)
            params["file"] = data

            println("Uploading chunk $chunk_idx...")
            res = HTTP.post(client, uri; body=params, verbose=true)
            if res.status != 200
                error("Upload failed with HTTP code $(res.status)")
            end
        end
    end
end

end #module client
