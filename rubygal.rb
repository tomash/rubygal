#!/usr/bin/env ruby
$:.unshift File.dirname(__FILE__)
require 'gallery_image'
require 'rubygems'
require 'RMagick'
require 'erb'

images = Dir["*.{gif,jpg,jpeg,png}"]
images.sort! # by name

width=120
height=120

FileUtils.mkdir_p "_rubygal"

for imagepath in images
  image_copy_path = "_rubygal/" + imagepath
  FileUtils.cp(imagepath, image_copy_path)
  
  ext = File.extname(imagepath)
  thumbname = imagepath.sub(ext,"t#{ext}")
  thumbpath = "_rubygal/" + thumbname
  if File.exist?(thumbpath)
    puts "file " + thumbpath + " already exists"
    next
  end
  puts "processing file #{imagepath} ..."
  imgobj = Magick::Image.read(imagepath).first

  thumbobj = imgobj.change_geometry("#{width}x#{height}") { |cols, rows, imgobj|
  imgobj.resize(cols, rows) }

  thumbobj.write(thumbpath)
  
  rhtml = ERB.new(File.new(File.dirname(__FILE__) + "/gallery_image.html.erb").read)
  @image = GalleryImage.new
  @image.filename = imagepath
  @image.thumb_filename = thumbname
  html_path = "_rubygal/" + imagepath.sub(ext,".html")
  html_file = File.new(html_path, "w")
  html_file.write(rhtml.result(binding))
  html_file.close
  
end
