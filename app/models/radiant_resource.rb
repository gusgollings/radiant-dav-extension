#
# Base class for all Radiant WebDav resources
#
class RadiantResource
  
  include WebDavResource

  attr_accessor :path, :record

  WEBDAV_PROPERTIES = [:displayname, :creationdate, :getlastmodified, :getcontenttype, :getcontentlength]

  #
  # Initializes a WebDav resource
  # +path+ path of the resource
  # +record+ ActiveRecord model if any
  #
  def initialize(path, record = nil)
    @path = path
    @record = record
    @children = []
  end

  #
  # Has this resource any childrens
  #
  def collection?
    return true
  end

  #
  # Remove the resource
  #
  def delete!
  end

  #
  # Move the resource
  # +dest_path+ the destination of the resource
  # +depth+ depth
  #
  def move! (dest_path, depth)
  end

  #
  # Copy the resource
  # +dest_path+ the destination of the resource
  # +depth+ depth
  #
  def copy! (dest_path, depth)
  end

  #
  # Returns the children of the resource
  #
  def children
    @children
  end

  #
  # Returns the WebDav properties
  #
  def properties
    WEBDAV_PROPERTIES
  end

  #
  # Returns the display name
  #
  def displayname
    path
  end

  #
  # Returns the creation date
  #
  def creationdate
    if !record.nil? and record.respond_to? :created_at
      record.created_at.httpdate
    end
  end

  #
  # Gets the last modified date
  #
  def getlastmodified
    if !record.nil? and record.respond_to? :updated_at
      record.updated_at.httpdate
    end
  end

  #
  # Updates the last modified date
  #
  def set_getlastmodified(value)
    if !record.nil? and record.respond_to? :updated_at=
      record.updated_at = Time.httpdate(value)
      gen_status(200, "OK").to_s
    else
      gen_status(409, "Conflict").to_s
    end
  end

  #
  # Returns the etag
  #
  def getetag
    #sprintf('%x-%x-%x', @st.ino, @st.size, @st.mtime.to_i) unless @file.nil?
  end

  #
  # Returns the content type
  #
  def getcontenttype
    "httpd/unix-directory"
  end

  #
  # Returns the the length of the content
  #
  def getcontentlength
    0
  end

  #
  # Returns the data of the resource
  #
  def data
    nil
  end

  #
  # Test if the actual resource is responsible for handling the request and
  # delegates the call to its children if not
  #
  # Returns the resource that is responsible, otherwise nil
  #
  def get_resource(resource_path)
    
    return self if path == resource_path

    @children.each do |c|
      resource = c.get_resource(resource_path)
      return resource if resource
    end if @children

    return nil
  end

  #
  # Determine the URL of this resource
  #
  # Returns a url
  #
  def href
    "/admin/dav/#{path}"
  end

  #
  # Determine the file extension depending on the resource's filter
  #
  # Returns a file extension
  #
  def filter_extension
    case record.filter_id
      when '', 'WymEditor'
        return ".html"
      when 'Textile'
        return ".textile"
      when 'Markdown'
        return ".markdown"
    end
  end

  #
  # Determine the file content type depending on the resource's filter
  #
  # Returns a file content type
  #
  def filter_content_type
    case record.filter_id
      when '', 'WymEditor'
        return "text/html"
      when 'Textile'
        return "text/plain"
      when 'Markdown'
        return "text/plain"
    end
  end
end