slices.model.Page = (
  function () {

    var settings,
        pageId,
        pageData,
        newSliceIdCounter = 0,
        NEW_SLICE_ID_NAME = '__new__',
        slicesInContainers = {};

    function load(callback) {
      $.ajax({
        url: settings.loadPagePath.split('{{id}}').join(pageId),
        contentType: 'application/json',
        dataType: 'json',
        error: function (XMLHttpRequest, textStatus, errorThrown) {
          // FIXME
          throw new Error(errorThrown);
        },
        success: function (data, textStatus, XMLHttpRequest) {
          parseLoadedData(data);
          callback();
        }
      });
    }

    function save() {
      var dfd = $.Deferred();

      var params = $.extend({}, pageData);

      _.each(params.slices, function (slice) {
        // Don't pass back the temp ID assigned to new slices so that the backend knows to
        // generate from scratch...
        if (slice.id.indexOf(NEW_SLICE_ID_NAME) === 0) {
          slice.client_id = slice.id;
          slice._new = 1;
          delete slice.id;
        }
        delete slice.template;
        delete slice.name;
      });

      /* Strip these out of the returned JSON object, only values
       * represented in the page form should be passed back HACKHACK */
      var do_not_pass_back = [
        'id',
        'position',
        'created_at',
        'updated_at',
        'has_content',
        'path',
        'page_id'];

      _.each(do_not_pass_back, function(item) {
        delete params[item]
      });

      $.ajax({
        url: settings.savePagePath.split('{{id}}').join(pageId),
        type: 'PUT',
        data: JSON.stringify({ page: params }),
        contentType: 'application/json',
        dataType: 'json',
        error: function (xhr, textStatus, errorThrown) {
          if (xhr.status == 422) {
            var errors = $.parseJSON(xhr.responseText);

            // If the slice is new re-assign the ids we stripped off when saving
            _.each(pageData.slices, function (slice) {
              if (slice._new) slice.id = slice.client_id;
            });

            dfd.reject(errors);
          } else {
            throw new Error(errorThrown);
          }
        },
        success: function (data, textStatus, XMLHttpRequest) {
          parseLoadedData(data);
          dfd.resolve();
        }
      });

      return dfd.promise();
    }

    function parseLoadedData(data) {
      pageData = data;

      _.each(slices.availableContainers, function (container, machineName) {
        slicesInContainers[machineName] = [];
      });

      pageData.slices = _.sortBy(pageData.slices, function (slice) {
        return slice.position;
      });

      _.each(pageData.slices, function (slice) {
        delete slice._new;

        try {
          slicesInContainers[slice.container].push(slice);
        } catch(error) {
          if (console != undefined) {
            console.log("Error, missing container on slice?", error, slice);
          }
        }
      });
    }

    function addSlice(slice) {
      slice.id = NEW_SLICE_ID_NAME + newSliceIdCounter++;
      pageData.slices.push(slice);
      slicesInContainers[slice.container].push(slice);
    }

    function positionSlice(sliceId, pos) {
      _.detect(pageData.slices, function (slice) {
        return slice.id == sliceId;
      }).position = pos;
    }

    return {
      init: function (s) {
        settings = s;
      },
      id: function (id) {
        if (arguments.length === 0) {
          return pageId;
        }
        pageId = id;
      },
      load: function (callback) {
        load(callback);
      },
      save: function () {
        return save();
      },
      field: function (varName) {
        return pageData[varName];
      },
      getSlices: function (container) {
        return slicesInContainers[container];
      },
      setSlices: function (container, slices) {
        slicesInContainers[container] = [];
        _.each(slices, function(slice) {
          pageData.slices = _.reject(pageData.slices, function(pdslice) {
            return pdslice.id === slice.id
          });
          pageData.slices.push(slice);
          slicesInContainers[container].push(slice);
        });
      },
      addSlice: function (slice) {
        addSlice(slice);
      },
      positionSlice: function (sliceId, pos) {
        positionSlice(sliceId, pos);
        changed = true;
      },
      getMeta: function(key) {
        return pageData[key];
      },
      setMeta: function(key, value) {
        pageData[key] = value;
      },
      // This returns true if the page was created in the last minute.
      seemsNew: function() {
        var created  = moment(this.field('created_at')),
            recently = moment().subtract('minutes', 1);

        return created >= recently && this.field('active') == false;
      },
      data: function() {
        return pageData;
      },
      slices: function() {
        return pageData.slices;
      }
    };
  }
)();
