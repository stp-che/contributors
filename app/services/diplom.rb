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
        t = pdf.bounds.top
        r = pdf.bounds.right
        pdf.text_box "PDF ##{@rank}", align: :center, size: 80, at: [0, t-100], width: r
        pdf.text_box 'The awards goes to', align: :center, size: 50, at: [0, t-220], width: r
        pdf.text_box @name, align: :center, size: 30, at: [0, t-310], width: r
      end.render
    end
  end
end