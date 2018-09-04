class RepoController < ApplicationController
  def index
    @address = params[:address]
    unless @address.blank?
      unless @address =~ /https?:\/\/(www\.)?github.com\/(.+)/
        @error = "#{@address.inspect} is not a github repo address"
      else
        begin
          @contributors = GithubStat.contributors($2)
        rescue GithubStat::Error => e
          @error = e.message
        end
      end
    end
  end

  def diplom
    diplom = Diplom.new params[:rank], params[:contributor]
    send_data diplom.content, filename: diplom.filename, disposition: :attachment
  end

  def diploms_archive
    diploms = params[:contributors].permit!.to_h.map{|rank, name| Diplom.new rank, name}
    send_data Diplom.get_archive(diploms), filename: 'archive.zip', disposition: :attachment
  end
end