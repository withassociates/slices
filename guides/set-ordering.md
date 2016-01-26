# Set Ordering

There are a few ways to go about this.

## 1. Using `default_scope`

```ruby
# app/slices/foo_set/foo.rb
class Foo < Page
  field :published_at, type: Time
  default_scope desc(:published_at)
end
```

**PROS:** Very obvious. Applies universally.  
**CONS:** Not obvious how to remove *just* this scope (`Foo.unscoped` removes all scopes).

## 2. Hard-code `sort_field` and `sort_direction` on the set slice

```ruby
# app/slices/foo_set/foo.rb
class Foo < Page
  field :published_at, type: Time
end

# app/slices/foo_set/foo_set_slice.rb
class FooSetSlice < SetSlice
  def sort_field
    :published_at
  end

  def sort_direction
    :desc
  end
end
```

**PROS:** Only affects entries admin UI and default set rendering.  
**CONS:** Inflexible. Non-obvious.

## 3. Use dynamic `sort_field` and `sort_direction` on the set slice

`sort_field` and `sort_direction` are fields, so we can give administrators control over them on a set-by-set basis.

```ruby
# app/slices/foo_set/foo.rb
class Foo < Page
  field :published_at, type: Time
end

# app/slices/foo_set/templates/foo_set.hbs
class FooSetSlice < SetSlice
end
```

```html
<li>
  <label for="slices-{{id}}-per_page">Per page</label>
  <input type="text" id="slices-{{id}}-per_page" value="{{per_page}}">
</li>

<li>
  <label for="slices-{{id}}-sort_field">Sort by</label>
  <select id="slices-{{id}}-sort_field" data-value="{{sort_field}}">
    <option value="name">Name</option>
    <option value="published_at">Publication Date</option>
  </select>
</li>

<li>
  <label for="slices-{{id}}-sort_direction">Sort direction</label>
  <select id="slices-{{id}}-sort_direction" data-value="{{sort_direction}}">
    <option value="asc">Ascending</option>
    <option value="desc">Descending</option>
  </select>
</li>
```

**PROS:** Flexible. Provides Administrator control.  
**CONS:** Potentially fragile. More setup.
