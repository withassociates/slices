# Container Options

## Setting a primary container

The edit page screen will show the first container in a layout as open by default. To choose a different container to be open by default, set it as primary:

```erb
<%= container "header" %>
<%= container "content", primary: true %>
```

## Restricting available slices

It's possible to restrict the slices available to a given container using the `only` and `except` options.

Only allow Text and Image slices:

```erb
<%= container "content", only: [TextSlice, ImageSlice] %>
```

Allow all slices except the Title slice:

```erb
<%= container "content", except: TitleSlice %>
```
