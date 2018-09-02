class RepoController < ApplicationController
  def index
    @address = params[:address]
    unless @address.blank?
      unless @address =~ /https?:\/\/(www\.)?github.com\/(.+)/
        @error = "#{@address.inspect} is not a github repo adress"
      else
        @result = GithubStat.contributors($2){|err|
          @error = err.message
        }
      end
    end
  end
end