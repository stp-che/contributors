class RepoController < ApplicationController
  def index
    @address = params[:address]
    unless @address.blank?
      unless @address =~ /https?:\/\/(www\.)?github.com\/(.+)/
        @error = "#{@address.inspect} is not a github repo adress"
      else
        begin
          @result = GithubStat.contributors($2)
        rescue GithubStat::Error => e
          @error = e.message
        end
      end
    end
  end
end