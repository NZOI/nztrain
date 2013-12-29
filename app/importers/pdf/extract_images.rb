# coding: utf-8

# This demonstrates a way to extract some images (those based on the JPG or
# TIFF formats) from a PDF. There are other ways to store images, so
# it may need to be expanded for real world usage, but it should serve
# as a good guide.
#
# Thanks to Jack Rusher for the initial version of this example.
#
# Notes: modified to suit nztrain

require 'pdf/reader'

module PDF::ExtractImages

  class Extractor
    attr_accessor :reader, :pdf_path
    def initialize(pdf_path, reader = PDF::Reader.new(pdf_path))
      self.pdf_path = pdf_path
      self.reader = reader
    end
    # reader is PDF::Reader
    # imagelist is in [[pagenumber, xobjectlabel, [x,y]],...] format
    def extract_images(imagelist)
      Hash[imagelist.map do |pg, name, pos|
        filename = extract_image(pg, name, reader.page(pg).xobjects[name], pos)
        [[pg, name], filename]
      end]
    end

    def self.xobjectfilename(pgnum, name, xobjstream)
      if xobjstream.hash[:Subtype] == :Form
        ext = 'png'
      elsif xobjstream.hash[:Subtype] == :Image
        ext = case xobjstream.hash[:Filter]
              when :CCITTFaxDecode; 'png'
              when :DCTDecode; 'jpg'
              else; 'png'
              end
      end
      "#{pgnum}-#{name}.#{ext}"
    end

    private
    def dirname
      File.dirname(pdf_path)
    end

    def expand_path(filename)
      File.expand_path(filename, dirname)
    end

    def extract_image(pg, name, stream, bbox = nil, to: name)
      filename = self.class.xobjectfilename(pg, name, stream)
      case stream.hash[:Subtype]
      when :Image then
        case stream.hash[:Filter]
        when :CCITTFaxDecode then
          PDF::ExtractImages::Tiff.new(stream).save(expand_path(filename + '.tif'))
          convert_to_format(filename + '.tif', filename)
        when :DCTDecode      then
          PDF::ExtractImages::Jpg.new(stream).save(expand_path(filename))
        else
          raw_extractor = PDF::ExtractImages::Raw.new(stream)
          if raw_extractor.supported?
            raw_extractor.save(expand_path(filename + '.tif'))
            convert_to_format(filename + '.tif', filename)
          else
            save_snapshot(pg, bbox, filename)
          end
        end
      when :Form then # to svg
        save_snapshot(pg, bbox, filename)
      end
      filename
    end

    def convert_to_format(imagename, newname)
      Magick::Image.read(expand_path(imagename)).first.write(expand_path(newname))
    end

    def save_snapshot(pg, bbox, filename)
      raise 'No bounding box' if bbox.nil?
      pdfbox = reader.page(pg).attributes[:MediaBox]
      bbox[1] = pdfbox[3] - bbox[1] - bbox[3] # flipping y-coordinate
      bbox[0] *= imagemagick_pages.x_resolution/72
      bbox[1] *= imagemagick_pages.y_resolution/72
      bbox[2] *= imagemagick_pages.x_resolution/72
      bbox[3] *= imagemagick_pages.y_resolution/72
      cropped_image = imagemagick_pages[pg-1].crop(*bbox)
      cropped_image.write(expand_path(filename))
    end

    def imagemagick_pages
      @magick ||= Magick::ImageList.new(pdf_path) { self.density = 150 }
    end

  end

  class Raw
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def supported?
      [:DeviceCMYK, :DeviceGray, :DeviceRGB].include?(colorspace)
    end

    def colorspace
      @stream.hash[:ColorSpace]
    end

    def save(filename)
      case colorspace
      when :DeviceCMYK then save_cmyk(filename)
      when :DeviceGray then save_gray(filename)
      when :DeviceRGB  then save_rgb(filename)
      else # :Indexed colorspace is unsupported
        $stderr.puts "unsupport color depth #{@stream.hash[:ColorSpace]} #{filename}"
      end
    end

    private

    def save_cmyk(filename)
      h    = stream.hash[:Height]
      w    = stream.hash[:Width]
      bpc  = stream.hash[:BitsPerComponent]
      len  = stream.hash[:Length]
      puts "#{filename}: h=#{h}, w=#{w}, bpc=#{bpc}, len=#{len}"

      # Synthesize a TIFF header
      long_tag  = lambda {|tag, count, value| [ tag, 4, count, value ].pack( "ssII" ) }
      short_tag = lambda {|tag, count, value| [ tag, 3, count, value ].pack( "ssII" ) }
      # header = byte order, version magic, offset of directory, directory count,
      # followed by a series of tags containing metadata.
      tag_count = 10
      header = [ 73, 73, 42, 8, tag_count ].pack("ccsIs")
      tiff = header.dup
      tiff << short_tag.call( 256, 1, w ) # image width
      tiff << short_tag.call( 257, 1, h ) # image height
      tiff << long_tag.call( 258, 4, (header.size + (tag_count*12) + 4)) # bits per pixel
      tiff << short_tag.call( 259, 1, 1 ) # compression
      tiff << short_tag.call( 262, 1, 5 ) # colorspace - separation
      tiff << long_tag.call( 273, 1, (10 + (tag_count*12) + 20) ) # data offset
      tiff << short_tag.call( 277, 1, 4 ) # samples per pixel
      tiff << long_tag.call( 279, 1, stream.unfiltered_data.size) # data byte size
      tiff << short_tag.call( 284, 1, 1 ) # planer config
      tiff << long_tag.call( 332, 1, 1)   # inkset - CMYK
      tiff << [0].pack("I") # next IFD pointer
      tiff << [bpc, bpc, bpc, bpc].pack("IIII")
      tiff << stream.unfiltered_data
      File.open(filename, "wb") { |file| file.write tiff }
    end

    def save_gray(filename)
      h    = stream.hash[:Height]
      w    = stream.hash[:Width]
      bpc  = stream.hash[:BitsPerComponent]
      len  = stream.hash[:Length]
      puts "#{filename}: h=#{h}, w=#{w}, bpc=#{bpc}, len=#{len}"

      # Synthesize a TIFF header
      long_tag  = lambda {|tag, count, value| [ tag, 4, count, value ].pack( "ssII" ) }
      short_tag = lambda {|tag, count, value| [ tag, 3, count, value ].pack( "ssII" ) }
      # header = byte order, version magic, offset of directory, directory count,
      # followed by a series of tags containing metadata.
      tag_count = 9
      header = [ 73, 73, 42, 8, tag_count ].pack("ccsIs")
      tiff = header.dup
      tiff << short_tag.call( 256, 1, w ) # image width
      tiff << short_tag.call( 257, 1, h ) # image height
      tiff << short_tag.call( 258, 1, 8 ) # bits per pixel
      tiff << short_tag.call( 259, 1, 1 ) # compression
      tiff << short_tag.call( 262, 1, 1 ) # colorspace - grayscale
      tiff << long_tag.call( 273, 1, (10 + (tag_count*12) + 4) ) # data offset
      tiff << short_tag.call( 277, 1, 1 ) # samples per pixel
      tiff << long_tag.call( 279, 1, stream.unfiltered_data.size) # data byte size
      tiff << short_tag.call( 284, 1, 1 ) # planer config
      tiff << [0].pack("I") # next IFD pointer
      p stream.unfiltered_data.size
      tiff << stream.unfiltered_data
      File.open(filename, "wb") { |file| file.write tiff }
    end

    def save_rgb(filename)
      h    = stream.hash[:Height]
      w    = stream.hash[:Width]
      bpc  = stream.hash[:BitsPerComponent]
      len  = stream.hash[:Length]
      puts "#{filename}: h=#{h}, w=#{w}, bpc=#{bpc}, len=#{len}"

      # Synthesize a TIFF header
      long_tag  = lambda {|tag, count, value| [ tag, 4, count, value ].pack( "ssII" ) }
      short_tag = lambda {|tag, count, value| [ tag, 3, count, value ].pack( "ssII" ) }
      # header = byte order, version magic, offset of directory, directory count,
      # followed by a series of tags containing metadata.
      tag_count = 8
      header = [ 73, 73, 42, 8, tag_count ].pack("ccsIs")
      tiff = header.dup
      tiff << short_tag.call( 256, 1, w ) # image width
      tiff << short_tag.call( 257, 1, h ) # image height
      tiff << long_tag.call( 258, 3, (header.size + (tag_count*12) + 4)) # bits per pixel
      tiff << short_tag.call( 259, 1, 1 ) # compression
      tiff << short_tag.call( 262, 1, 2 ) # colorspace - RGB
      tiff << long_tag.call( 273, 1, (header.size + (tag_count*12) + 16) ) # data offset
      tiff << short_tag.call( 277, 1, 3 ) # samples per pixel
      tiff << long_tag.call( 279, 1, stream.unfiltered_data.size) # data byte size
      tiff << [0].pack("I") # next IFD pointer
      tiff << [bpc, bpc, bpc].pack("III")
      tiff << stream.unfiltered_data
      File.open(filename, "wb") { |file| file.write tiff }
    end
  end

  class Jpg
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def save(filename)
      w = stream.hash[:Width]
      h = stream.hash[:Height]
      puts "#{filename}: h=#{h}, w=#{w}"
      File.open(filename, "wb") { |file| file.write stream.data }
    end
  end

  class Tiff
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def save(filename)
      if stream.hash[:DecodeParms][:K] <= 0
        save_group_four(filename)
      else
        $stderr.puts "#{filename}: CCITT non-group 4/2D image."
      end
    end

    private

    # Group 4, 2D
    def save_group_four(filename)
      k    = stream.hash[:DecodeParms][:K]
      h    = stream.hash[:Height]
      w    = stream.hash[:Width]
      bpc  = stream.hash[:BitsPerComponent]
      mask = stream.hash[:ImageMask]
      len  = stream.hash[:Length]
      cols = stream.hash[:DecodeParms][:Columns]
      puts "#{filename}: h=#{h}, w=#{w}, bpc=#{bpc}, mask=#{mask}, len=#{len}, cols=#{cols}, k=#{k}"

      # Synthesize a TIFF header
      long_tag  = lambda {|tag, value| [ tag, 4, 1, value ].pack( "ssII" ) }
      short_tag = lambda {|tag, value| [ tag, 3, 1, value ].pack( "ssII" ) }
      # header = byte order, version magic, offset of directory, directory count,
      # followed by a series of tags containing metadata: 259 is a magic number for
      # the compression type; 273 is the offset of the image data.
      tiff = [ 73, 73, 42, 8, 5 ].pack("ccsIs") \
      + short_tag.call( 256, cols ) \
      + short_tag.call( 257, h ) \
      + short_tag.call( 259, 4 ) \
      + long_tag.call( 273, (10 + (5*12) + 4) ) \
      + long_tag.call( 279, len) \
      + [0].pack("I") \
      + stream.data
      File.open(filename, "wb") { |file| file.write tiff }
    end
  end
end
