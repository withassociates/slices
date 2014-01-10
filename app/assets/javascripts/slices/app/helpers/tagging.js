var Tagging = {

  detect: function() {
    var self = this;
    $('.multi-tag-list').each(function(index, tag_list) {
      self.setup_multi(tag_list);
    });
    $('.single-tag-list').each(function(index, tag_list) {
      self.setup_single(tag_list);
    });
  },

  setup_single: function(tag_list) {
    var self = this;
    var $tag_list = $(tag_list);
    if ($tag_list.length) {
      var $tag_input = $tag_list.parent().find('input');
      $tag_list.children('li').click(function(event) {
        var $el = $(event.target)
        var tagvalue =  $.trim($el.text()).replace(/\,\s*$/,'');
        $tag_input.val(tagvalue).trigger('change');
        self.mark_active_tags($tag_list, $tag_input.val());
      });

      self.mark_active_tags($tag_list, $tag_input.val());
    }
  },

  setup_multi: function(tag_list) {
    var self = this;
    var $tag_list = $(tag_list)
    if ($tag_list.length) {
      var $tag_input = $tag_list.parent().find('input');

      $tag_list.children('li').click(function(event) {
        var $el = $(event.target);
        var tagvalue = $.trim($el.text()).replace(/\,\s*$/, '');
        var regex = new RegExp(tagvalue + ',?')

        if ($el.hasClass('on')) { //remove the tag
          var new_value = $tag_input.val().replace(regex, '');
          new_value = self.strip_whitespace(new_value);
          $tag_input.val(new_value).trigger('change');
          $el.removeClass('on');
        } else { //add the tag
          var new_value = ($tag_input.val() + ', ' + tagvalue);
          new_value = self.strip_whitespace(new_value);
          $tag_input.val(new_value).trigger('change');
          $el.addClass('on');
        }
      });
      self.mark_active_tags($tag_list, $tag_input.val());
    }
  },

  mark_active_tags: function($tag_list, current_tags) {
    var self = this;
    $tag_list.children('li').each(function(index, tag) {
      var $tag = $(tag);
      var regex = new RegExp(self.strip_whitespace($tag.text()));
      if (current_tags.match(regex)) {
        $tag.addClass('on');
      } else {
        $tag.removeClass('on');
      }
    });
  },

  strip_whitespace: function(string) {
    string = string.replace(/[\,\s\s+]*$/g,'').replace(/^[\,\s+]*/g,'').replace(/\s\s+/,' ');
    return string;
  }
}
