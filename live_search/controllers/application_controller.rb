class ApplicationController < ActionController::Base
  before_filter :check_search_params, :only => [:show_search_param]

  def show_search_param
    @search = params["search"] || {}
    respond_to do |format|
      format.js {render "shared/search/show_param"}
    end
  end

  def check_search_params
    @partial = params["id"] || (params["search"].keys[0])
    unless valid_search_params.include?( @partial.to_sym )
      respond_to do |format|
        format.html
        format.js {render "shared/errors"}
      end
    end
  end

  def valid_search_params
    []
  end

end
