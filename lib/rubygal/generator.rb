module Rubygal
  class Generator
    attr_accessor :template_dir
    
    def initialize(dest_dir = "_rubygal")
      @dest_dir = dest_dir
    end
    
    def generate(images)
      @images = images
      width  = 120
      height = 120
      FileUtils.mkdir_p @dest_dir
      
      @gallery = Gallery.new
      for imagepath in images
        FileUtils.cp(imagepath, File.join(@dest_dir, imagepath))
        
        ext = File.extname(imagepath)
        thumbname = imagepath.sub(ext,"t#{ext}")
        thumbpath = File.join(@dest_dir, thumbname)
        if File.exist?(thumbpath)
          puts "file " + thumbpath + " already exists"
          next
        end
        puts "processing file #{imagepath} ..."
        imgobj = Magick::Image.read(imagepath).first
      
        thumbobj = imgobj.change_geometry("#{width}x#{height}") { |cols, rows, imgobj|
        imgobj.resize(cols, rows) }
      
        thumbobj.write(thumbpath)
        
        rhtml = ERB.new(File.new(template_dir + "/gallery_image.html.erb").read)
        @image = GalleryImage.new
        @image.filename = imagepath
        @image.thumb_filename = thumbname
        @image.page_filename = imagepath.sub(ext,".html")
        html_path = File.join(@dest_dir, @image.page_filename)
        html_file = File.new(html_path, "w")
        html_file.write(rhtml.result(binding))
        html_file.close
        
        @gallery.images << @image
        
        rhtml = ERB.new(File.new(template_dir + "/gallery.html.erb").read)
        html_path = File.join(@dest_dir, "index.html")
        html_file = File.new(html_path, "w")
        html_file.write(rhtml.result(binding))
        html_file.close
      end
      
    end
  end
end
