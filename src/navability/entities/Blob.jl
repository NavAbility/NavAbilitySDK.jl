struct FileInput
  filename::String
  filesize::Int
end

struct File
  id::String
  filename::String
  filesize::Int
  hash::String
  mimetype::String
end

struct CompletedUploadPartInput
  partNumber::Int
  eTag::String
end

struct CompletedUploadInput
  uploadId::String
  parts::Vector{CompletedUploadPartInput}
end

struct UploadPart
  partNumber::Int
  url::String
end

struct UploadInfo
  uploadId::String
  parts::Vector{UploadPart}
  file::File
  expiration::String
end