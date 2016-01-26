# Customising the Navbar

Custom items can be added to Slices’ navbar in the manner described below.

## Adding items to the left side

Add the following to `app/views/admin/shared/_custom_navigation.html.erb`:

```erb
<%= admin_nav_link "Example Label", example_path %>
```

Which will result in this HTML:

```html
<li id="admin_nav_sources">
  <a href="https://github.com/withassociates/slices">Source</a>
</li>
```

To set an icon, add the following to `public/stylesheets/admin.css`:

```css
#admin_nav_sources a {
  background-image: url(/images/admin/icon_example.svg);
}
```

You’ll need to have created `public/images/admin/icon_example.svg` too.

## Adding items to the right side

Add the following to `app/views/admin/shared/_custom_links.html.erb`:

```erb
<li><%= link_to 'Example', example_path %></li>
```

Which will render just before the 'View Site' link.
