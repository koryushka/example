json.extract! document, :id, :title, :notes, :tags
json.file do
  json.partial! 'api/v1/files/file', file: document.uploaded_file
end