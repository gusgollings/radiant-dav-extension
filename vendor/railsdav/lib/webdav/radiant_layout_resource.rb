require 'find'
class RadiantLayoutResource
  include WebDavResource

  attr_accessor :html, :record, :table

  WEBDAV_PROPERTIES = [:displayname, :creationdate, :getlastmodified, :getcontenttype, :getcontentlength]
  @@classes = Hash.new
   
   def initialize(*args)
       obj = args.first
       
       #bit hackey but kind_of? ActiveRecord::Base isnt working
       if obj.respond_to?(:save)
         @record = obj
       end
       if obj.is_a?(Class)
         @table = obj
       end

       @href = "/#{@record.slug}"      
    end

    def href
      record && record.url rescue "/"
    end

    def collection?
      false
    end

    def delete!
      record.destroy! unless record.nil?
    end

    def move! (dest_path, depth)
      
    end

    def copy! (dest_path, depth)
      
    end

    # The children of a Radiant page are its child pages and/or parts
    def children
     return []
    end
  
   def properties
     WEBDAV_PROPERTIES
   end 

   def displayname
      return "#{record.slug.to_s}" unless record.nil?
      # return @@classes.index(table) unless table.nil?
      # "/"
   end
   
   def creationdate
      if !record.nil? and record.respond_to? :created_at
        record.created_at.httpdate
      end
   end
   
   def getlastmodified
      if !record.nil? and record.respond_to? :updated_at
        record.updated_at.httpdate
      end
   end
   
   def set_getlastmodified(value)
     if !record.nil? and record.respond_to? :updated_at=
      record.updated_at = Time.httpdate(value)
      gen_status(200, "OK").to_s
     else
        gen_status(409, "Conflict").to_s
     end
   end
   
   def getetag
      #sprintf('%x-%x-%x', @st.ino, @st.size, @st.mtime.to_i) unless @file.nil?
   end
      
   def getcontenttype
      "text/html"
   end
      
   def getcontentlength 
      record.content.size
   end
   
   def data
     record.content
   end
   
end