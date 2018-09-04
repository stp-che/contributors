require 'archive/zip'

class Diplom

  class << self
    def get_archive(diploms)
      res = nil
      Dir.mktmpdir do |dir|
        diploms.each do |d|
          File.open("#{dir}/#{d.filename}", 'wb'){|f| f << d.content}
        end
        Archive::Zip.archive "#{dir}/archive.zip", diploms.map{|d| "#{dir}/#{d.filename}"}
        res = File.binread "#{dir}/archive.zip"
      end
      res
    end
  end

  def initialize(rank, name)
    @rank, @name = rank, name
  end

  def filename
    "#{@name}.pdf"
  end

  def content
    @content ||= begin
      Prawn::Document.new.tap do |pdf|
        pdf.text "PDF ##{@rank}"
        pdf.text 'The awards goes to'
        pdf.text @name
      end.render
    end
  end
end