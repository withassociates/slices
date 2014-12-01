//     Slices.js
//     (c) 2011 With Associates
//     http://slices.withassociates.com/

var slices = {

  defaultSettings: {
    mainTemplate: '_page_main',
    metaTemplate: '_page_meta',
    templatesPath: '/slices/templates/',
    loadPagePath: '/admin/pages/{{id}}.json',
    savePagePath: '/admin/pages/{{id}}.json'
  },

  templates: {},
  availableSlices: {},
  availableContainers: {},
  model: {},

  fieldId: function(context, field) {
    // If `this` is the current page, then we’ll use a `meta-{{field}}` ID.
    if (context === slices.model.Page.data()) {
      return ['meta', field].join('-');

    // If this has an id, we’re dealing with a slice, so we’ll use a `slices-{{id}}-{{field}}` ID.
    } else if (context.hasOwnProperty('id')) {
      return ['slices', context.id, field].join('-');

    // Otherwise, we just need a unique id.
    } else {
      slices.__uid__ = slices.__uid__ || 0;
      return 'field-' + ++slices.__uid__;
    }
  },

  controller: function SlicesController() {

    // private vars
    var settings,
        busy = true;

    // private methods

    function init(pageId, passed_settings) {
      settings = $.extend({}, slices.defaultSettings, passed_settings);

      observeFormEvents();

      slices.model.Page.init(settings);
      slices.model.Page.id(pageId);

      slices.availableContainers = settings.availableContainers;
      slices.availableSlices = settings.availableSlices;


      addSliceOptions(slices.availableSlices);

      templates = [
        'slice',
        settings.mainTemplate,
        settings.metaTemplate,
        settings.mainExtraTemplate,
        settings.metaExtraTemplate
      ];

      loadSliceTemplates(pageId);
      loadTemplates(templates, pageId, loadPageModel);
    };

    function addSliceOptions(slices) {
      var select = $('#add-slice-fields select');

      select.find('option:not(:disabled)').remove();

      _.each(slices, function (slice, machineName) {
        if (!restrictedAndNotSuper(slice)) {
          select.append(
            '<option value="' + machineName + '">' + slice.name + '</option>'
          );
        }
      });
    };

    function templateUrl(name, pageId) {
      name = name.split('{{id}}').join(pageId);

      if (name.indexOf('/') === 0) {
        return name + '.hbs';
      } else {
        return settings.templatesPath + name + '.hbs';
      }
    };

    function loadSliceTemplates(pageId) {
      _.each(slices.availableSlices, function(slice, name) {
        $.ajax({
          url: templateUrl(slice.template, pageId),
          success: function(raw_template, textStatus, XMLHttpRequest) {
            slices.templates[slice.template] = Handlebars.compile(raw_template);
          }
        });
      })
    };

    function loadTemplates(templates, pageId, callback) {
      templates = _.compact(templates);
      var numTemplates = templates.length;
      _.each(templates, function (templateName) {
        $.ajax({
          url: templateUrl(templateName, pageId),
          success: function (raw_template, textStatus, XMLHttpRequest) {
            slices.templates[templateName] = Handlebars.compile(raw_template);
            if (--numTemplates == 0) callback();
          }
        });
      });
    };

    function loadPageModel() {
      slices.model.Page.load(onPageLoaded);
    };

    function addSliceTemplate(slice) {
      var templateData = {},
          sliceBlock,
          sliceContent,
          sliceContentTemplate = slices.availableSlices[slice.type].template,
          isOpen = false;

      var sliceBlock = $(
        slices.templates['slice']({
          id: slice.id,
          name: slice.name,
          css_class: slice.type + '-slice',
          content: function () {
            return slices.templates[sliceContentTemplate](slice)
          }
        })
      );

      var sliceContent = sliceBlock.find('.slice-content'),
          controlBar = sliceBlock.find('.control-bar'),
          preview = sliceBlock.find('.slice-preview');

      if (_.isFunction(window.customSlicePreview)) {
        var slicePreviewHelper = window.customSlicePreview;
        delete window.customSlicePreview;
      } else {
        var slicePreviewHelper = slices.defaultSlicePreview;
      }

      var updateSlicePreview = function() {
        preview.html(slicePreviewHelper.call(sliceContent));
      }

      updateSlicePreview();

      controlBar.on('click', function () {
        var closed = sliceBlock.is('.closed');

        if (closed) {
          sliceContent.slideDown('fast');
          sliceBlock.removeClass('closed');
        } else {
          updateSlicePreview();
          sliceContent.slideUp('fast');
          sliceBlock.addClass('closed');
        }

        updateMinimiseAllSlices();

        return false;
      });

      sliceBlock.find('a.sort').on('click', false);

      if (restrictedAndNotSuper(slice)) {
        sliceBlock.find('a.delete').remove();
      } else {
        sliceBlock.find('a.delete').on('click', function () {
          slice._destroy = 1;
          sliceBlock.slideUp('fast');
          sliceBlock.trigger('change');
          enableSaveButton();
          return false;
        });
      }

      $('#container-' + slice.container + '>ul').append(sliceBlock);

      sliceContent.applyDataValues();
      sliceContent.initDataPlugins();

      enableContainerSelect(slice, sliceBlock);

    }

    function onPageLoaded() {
      var tabControls = $('#container-tab-controls'),
          containersHolder = $('#containers-holder').empty(),
          addSliceFields = $('#add-slice-fields');

      initMeta();

      _.each(slices.availableContainers, function (container, machineName) {
        // Create ourselves a tab button.
        var tabButton = $(
          '<a href="#container-' + machineName + '">' +
            container.name +
          '</a>'
        );

        if (container.primary) tabButton.addClass('primary');

        container.availableSlices = _.clone(slices.availableSlices);

        // Filter available slices to those specified in the layout

        if (container.only) {
          _.each(slices.availableSlices, function(slice, machineName) {
            if (!_.contains(container.only, machineName)) {
              delete container.availableSlices[machineName];
            }
          });
        }

        if (container.except) {
          _.each(slices.availableSlices, function(slice, machineName) {
            if (_.contains(container.except, machineName)) {
              delete container.availableSlices[machineName];
            }
          });
        }

        tabButton.data('container', container);

        // Bind the tab button click event.
        tabButton.on('click', function() {
          var tab = $(this);
          var container = tab.data('container');

          tabControls.find('a').removeClass('active');
          containersHolder.find('>div').hide();
          $('#container-' + machineName).show();
          $(this).addClass('active');

          updateMinimiseAllSlices();
          addSliceOptions(container.availableSlices);

          return false;
        });

        // Append our tab button (in an li) to the tab controls container.
        tabControls.append($('<li />').append(tabButton));

        // Create ourselves a container, holder and adder.
        var container = $('<div id="container-' + machineName + '" class="container" />');
        var holder = $('<ul class="slices-holder" />');
        var adder = addSliceFields.clone();

        // Remove redundant id attribute on our cloned adder.
        // adder.attr({ id: '' });

        // Bind the behaviour of our slice selector.
        adder.find('select').bind('change', function() {
          var sliceType = $(this).val();

          if (sliceType === '') return false;

          addNewSlice(
            machineName,
            $(this).val(),
            $('#container-' + machineName + ' ul li').length
          );

          $('#container-' + machineName + ' ul').trigger('sortstop');

          $(this).find('option:selected').removeAttr('selected');
          $(this).find('option:disabled').attr('selected', 'selected');

          return false;
        });

        // Glue everything together.
        container.append(holder, adder);
        containersHolder.append(container);
      });

      addSliceFields.remove();
      tabControls.find('a:first, a.primary').trigger('click');
      addSliceContainers();
      addMinimiseAllSlices();

      if ($('#page-meta').children().length > 0) {
        $('<div id="show-meta"><a href="#">advanced options&hellip;</a></div>').
        insertAfter('#page-meta').
        toggle(function() {
          $('#page-meta').slideDown('fast');
          $(this).html('<a href="#">hide advanced options</a>');
          $(this).addClass('open');
          $(document).trigger('slices:didShowAdvancedOptions');
        }, function() {
          $('#page-meta').slideUp('fast');
          $(this).html('<a href="#">advanced options&hellip;</a>');
          $(this).removeClass('open');
          $(document).trigger('slices:didHideAdvancedOptions');
        });

        if (slices.model.Page.seemsNew()) $('#show-meta').trigger('click');
      }

      busy = false;
    }

    function initMeta() {
      $('#page-main').html(renderMetaFields(settings.mainTemplate));

      $('#page-meta').html(renderMetaFields(settings.metaTemplate));

      if (settings.metaExtraTemplate) {
        $('#page-meta').append(renderMetaFields(settings.metaExtraTemplate));
      }

      if (settings.mainExtraTemplate) {
        $('#page-extra-main').html(renderMetaFields(settings.mainExtraTemplate));
      }

      $('#page-meta-fields').applyDataValues().initDataPlugins();

      Tagging.detect();
    }

    function renderMetaFields(name) {
      var template = slices.templates[name],
          page     = slices.model.Page,
          data     = page.data();

      return template(data);
    }

    function addNewSlice(container, type, pos) {
      var slice = _.extend({}, slices.availableSlices[type], {
        type: type,
        container: container,
        position: pos
      });
      slices.model.Page.addSlice(slice);
      addSliceTemplate(slice);
    }

    function addSliceContainers() {
      _.each(slices.availableContainers, function (container, machineName) {
        $('#container-' + machineName + ' ul').empty();
      });

      _.each(slices.availableContainers, function (container, machineName) {
        var container_slices = slices.model.Page.getSlices(machineName);

        container_slices = _.map(container_slices, function(slice) {
          return $.extend(true, {},
            slices.availableSlices[slice.type],
            slice
          );
        });

        slices.model.Page.setSlices(machineName, container_slices);

        _.each(container_slices, addSliceTemplate);

        var ul = $('#container-' + machineName + '>ul');

        ul.sortable({
          handle: '.control-bar',
          scroll: false,
          beforeStart: function() {
            ul.freezeHeight();
            window.autoscroll.start();
          },
          stop: function() {
            window.autoscroll.stop();
            ul.thawHeight();
          }
        });

        ul.on('sortstop', function (event, ui) {
          ul.find('>li').each(function (i) {
            slices.model.Page.positionSlice($(this).attr('rel'), i);
          });

          onReorder();
        });

        ul.trigger('sortstop');
      });
    }

    function addMinimiseAllSlices(){
      var minimise = $('#minimise');
      minimise.text('Minimise all slices');

      minimise.on('click', function () {
        if (minimise.text().indexOf('Minimise') != -1){
          $('.container:visible .slice:not(.closed) .control-bar').click();
        } else {
          $('.container:visible .slice.closed .control-bar').click();
        }
        return false;
      })
    }

    function updateMinimiseAllSlices() {
      var slices = $('.container:visible .slice');

      if (slices.length === 0) return;

      var closed = slices.filter('.closed'),
          allClosed = closed.length === slices.length,
          allOpen = closed.length === 0;

      if (allClosed) {
        $('#minimise').text('Expand all slices');
      } else if (allOpen) {
        $('#minimise').text('Minimise all slices');
      }
    }

    function getArrayInputValuesFor(key) {
      var result = [];

      $('input[name="meta-' + key + '"]').each(function() {
        var input = $(this);

        switch (input.attr('type')) {
          case 'checkbox':
            if (input.is(':checked')) result.push(input.val());
          break;
          default:
            result.push(input.val());
          break;
        }
      });

      return result;
    }

    function updateMeta() {
      var model = slices.model.Page,
          inputs = $('[id^="meta-"]');

      inputs.each(function() {
        var input = $(this),
            id = input.attr('id'),
            key = id.match(/meta-(.+)/)[1],
            oldValue = model.getMeta(key),
            newValue = slices.getValueForId(id);

        if (newValue === undefined || newValue == oldValue) return;

        model.setMeta(key, newValue);
        model.changed = true;
      });
    }

    function updateSlices() {
      var model = slices.model.Page;

      _.each(model.slices(), function(slice) {
        var prefix = 'slices-' + slice.id + '-',
            inputs = $('[id^="' + prefix + '"]');

        inputs.each(function() {
          var input = $(this),
              id = input.attr('id'),
              key = id.substr(prefix.length),
              oldValue = slice[key],
              newValue = slices.getValueForId(id);

          if (newValue === undefined || newValue == oldValue) return;

          slice[key] = newValue;
          model.changed = true;
        });
      });
    }

    function updateModel() {
      var model = slices.model.Page;

      model.changed = false;

      updateMeta()
      updateSlices();

      if (model.changed) enableSaveButton();
    }

    function observeFormEvents() {
      $('#slices-form')
      .on('submit', onFormSubmitted)
      .on('change', onChange)
      .on('keyup', 'input, textarea', _.debounce(function() {
        $(this).trigger('change');
      }, 100));
    }

    function onChange() {
      if (!busy) updateModel();
    }

    function onReorder() {
      if (!busy) enableSaveButton();
    }

    function onFormSubmitted(event) {
      event.preventDefault();

      busy = true;

      $(document).trigger('slices:willSubmit');

      updateModel();

      disableSaveButton();

      $('.error-message').remove();
      $('.field-with-errors').removeClass('field-with-errors');
      $('#container').freezeHeight();

      // Save it...
      slices.model.Page.save()
      .done(function() {
        initMeta();
        addSliceContainers();
        updateViewLink();
        updateBreadcrumbs();
      })
      .fail(function(errors) {
        _.each(errors, function(value, key) {
          if (key == 'slices') {
            value = _.flatten([value])[0];
            _.each(value, function(fields, sliceId) {
              _.each(fields, function(errorMsgs, fieldName) {

                var inpId = ['slices', sliceId, fieldName].join('-'),
                    input = $('#' + inpId);

                input.closest('li').addClass('field-with-errors');

                var errorMsg = _.flatten([errorMsgs]).join(', ');
                input.after(
                  $('<div class="error-message" />').text(
                    $('label[for=' + inpId + ']').text() + ' ' + errorMsg
                  )
                );

                var containerId = input.closest('.container').attr('id');

                $('#container-tab-controls a[href=#' + containerId + ']')
                .addClass('field-with-errors');
              });
            });
          } else {
            var li = $('#meta-' + key).closest('li');

            li
            .addClass('field-with-errors')
            .append(
              $('<div class="error-message" />').text(
                li.find('.label').text() + ' ' + value
              )
            );
          }
        });
      }).
      always(function() {
        disableSaveButton();
        updateMinimiseAllSlices();
        busy = false;
        _.defer(function() { $('#container').thawHeight() });
      });
    }

    function restrictedAndNotSuper(slice) {
      return (slice.restricted && !settings.super_user);
    }

    // Rig-up the little container select widget in the control bar.
    // This is not the prettiest, but you don't need me to tell you that,
    // you can just look below.
    function enableContainerSelect(slice, sliceBlock) {

      var potentialContainers = {};

      _.each(slices.availableContainers, function(container, machineName) {
        if (container.availableSlices.hasOwnProperty(slice.type)) {
          potentialContainers[machineName] = container;
        }
      });

      if (Object.keys(potentialContainers).length <= 1) {
        sliceBlock.find('.container-select').remove();
        return;
      }

      sliceBlock.find('.container-select').each(function() {
        var select = $(this);

        // Add the options
        select.append('<option value="default" selected disabled>Move to another container</option>');

        _.each(potentialContainers, function(container, machineName) {
          select.append('<option value="' + machineName + '">' + container.name + '</option>');
        });

        // On change, we'll move our slice to the selected container
        // and notify all the appropriate objects that things have changed.
        select.bind('change', function() {
          // Attach to the new container, both in data and dom.
          var newMachineName = select.val();
          var newContainer = $('#container-' + newMachineName + ' > ul');
          slice.container = newMachineName;
          sliceBlock.detach().appendTo(newContainer);

          // Reset the widget.
          select.val('default');

          // Make sure slice positions are accurate.
          newContainer.find('> li').each(function(i) {
            slices.model.Page.positionSlice($(this).attr('rel'), i);
          });

          // Fire re-order hooks.
          onReorder();
        });
      });
    }

    // Enables/disables the 'Save changes' button.
    function enableSaveButton() {
      $('#save-changes').attr('disabled', false);
    }
    function disableSaveButton() {
      $('#save-changes').attr('disabled', true);
    }

    function updateViewLink() {
      $('#page-view-on-site').attr('href', slices.model.Page.data().path);
    }

    function updateBreadcrumbs() {
      $('#breadcrumbs .current a').html(slices.model.Page.data().name);
    }

    // public API
    return {
      init: function (pageId, settings) {
        return init(pageId, settings);
      }
    }

  }()
};

