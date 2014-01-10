require 'will_paginate/view_helpers/action_view'

class SetLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  protected
    # This method has been largely robbed from will_paginate's
    # lib/will_paginate/view_helpers/action_view.rb file, whose
    # implementation only differs in that it assumes that you're using
    # controller: 'foo', action: 'bar' compatible routes.
    #
    def url(page)
      @base_url_params ||= begin
        url_params = base_url_params
        merge_optional_params(url_params)
        url_params
      end

      url_params = @base_url_params.dup
      path = url_params.delete(:path)
      add_current_page_param(url_params, page)
      remove_unwanted_params(url_params)
      if url_params.empty?
        "/#{path}"
      else
        "/#{path}?" + url_params.map { |k, v| "#{k}=#{v}" }.join('&')
      end
    end

    def remove_unwanted_params(url_params)
      [:controller, :action, :escape].each { |p| url_params.delete(p) }
    end
end
