# Creating Sets

1. Create a set Slice:

   ```shell
   $ rails generate slice post_set
   ```

2. Create the Placeholder Slice (you can skip this step if it already exists!):

   ```shell
   $ mkdir -p app/slices/placeholder/templates && \
   echo "require File.join(Slices.gem_path, 'app', 'models', 'placeholder_slice')" > app/slices/placeholder/placeholder_slice.rb && \
   echo "<li><em>The content for each entry will be rendered here.</em></li>" > app/slices/placeholder/templates/placeholder.hbs
   ```

4. After restarting your server, create a page in the CMS and convert it to a
   set page:

   ```shell
   $ rails runner 'Page.find_by_path("/blog").update_attributes(_type: "SetPage")'
   ```

   **NOTE:** Replace `"/blog"` with the path of your set page.

5. Edit the index template and add your Post Set Slice to the appropriate
   container. This controls how many Posts are displayed in the Post index.

6. Edit the entry template and add the Placeholder Slice to the appropriate
   container(s). This will display a Post's slices when viewing an individual
   Post.
