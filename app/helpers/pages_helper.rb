# This module provides helper methods rendering pages and slices.
module PagesHelper
  include NavigationHelper
  include AssetsHelper

  # Defines and renders a container in a layout.
  #
  # For example adding the following to a layout will create two containers called
  # container_one and container_two
  #
  #   <article class="container_one">
  #     <%= container "container_one" %>
  #   </article>
  #   <aside class="container_two">
  #     <%= container "container_two" %>
  #   </aside>
  #
  # @param [String]   container     Name of container
  # @return [String]                Contents of rendered slices in container
  #
  def container(container, options = {})
    if @slice_renderer.present?
      @slice_renderer.render_container(container)
    end
  end

  # Returns the text with all the Textile[http://www.textism.com/tools/textile] codes turned into HTML tags.
  #
  # @param [String] text              Text to be textilized
  # @return [String]                  Textilized string
  #
  def textilize(text)
    unless text.blank?
      red_cloth = RedCloth.new(text)
      red_cloth.no_span_caps = true
      red_cloth.to_html.html_safe
    end
  end

  # Converts markdown to html.
  #
  # @param [String] text
  # @return [String]
  #
  def markdown(text)
    return if text.blank?
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    parser = Redcarpet::Markdown.new(renderer)
    parser.render(text).html_safe
  end

  # Quick link to edit the current page in the CMS
  #
  # @return [String]                      Edit in CMS link
  #
  def edit_in_cms
    if admin_signed_in?
      links = []
      links << link_to("Edit #{@page.class.to_s.underscore.humanize} in CMS", admin_page_path(@page), target: '_blank')
      links << link_to('Edit template in CMS', admin_page_path(@page.parent, entries: 1), target: '_blank') if @page.entry?
      content = links.collect {|l| content_tag(:p, l) }.join.html_safe

      content_tag(:div, content, id: 'edit_in_cms')
    end
  end

  # Translates the key and return an empty string if there is no translation.
  #
  #
  # @param [String] key                   Translation key
  # @param [Hash]   options
  # @return [String]                      Translated key
  #
  def if_t(key, options = {})
    translate(key, options) || ''
  end

  # Asynchronous Google Analytics Tracking Code. Only added in production when the
  # user is not signed into the CMS.
  #
  #     google_analytics_tracking_code('ABC132')
  #
  # To track multiple accounts use the following
  #
  #     google_analytics_tracking_code('ABC132', 'DEF546')
  #
  # @param [Array, String]  web_property_ids        Web property ID(s)
  # @return [String]                                GA embed code
  #
  def google_analytics_tracking_code(*web_property_ids)
    if web_property_ids.first.present? && add_tracking_code?
      analytics_que = "['_setAccount', '#{web_property_ids.shift}'], ['_trackPageview'], ['_trackPageLoadTime']"
      web_property_ids.each_with_index do |web_property_id, index|
        account = (index + 98).chr
        analytics_que << ", ['#{account}._setAccount', '#{web_property_id}'], ['#{account}._trackPageview'], ['#{account}._trackPageLoadTime']"
      end

      javascript_tag <<-JAVASCRIPT
var _gaq = _gaq || [];
_gaq.push(#{analytics_que});
(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();
      JAVASCRIPT
    end
  end

  # If a tracking code should be added to the page. Returns +true+ when the app
  # is in production mode and the user is not signed into the CMS
  #
  # @return [Boolean]
  #
  def add_tracking_code?
    Rails.env.production? && ! admin_signed_in?
  end
end

