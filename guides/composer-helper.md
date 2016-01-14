# Composer Helper

Composer fields are useful when you want to create sortable sets of content
composed of specific fields. You might hear the term "repeater" in other
systems, but we use "composer". To place one in a Slice, or in Page meta
fields, use the helper as follows:

```ruby
class RecipeSlice < Slice
  field :ingredients, type: Array
  field :steps, type: Array
end
```

```html
<li>
  <label for="slices-{{id}}-ingredients">Ingredients</label>
  {{#composer field="ingredients"}}
    <input type="text" name="name" placeholder="Name (e.g. Cheese)…" value="{{name}}">
    <input type="text" name="amount" placeholder="Amount (e.g. 10kg)…" value="{{amount}}">
  {{/composer}}
</li>
<li>
  <label for="slices-{{id}}-steps">Steps</label>
  {{#composer field="steps"}}
    <input type="text" name="title" placeholder="Title (e.g. Preparation)…" value="{{title}}">
    <textarea type="text" name="instructions" placeholder="Instructions…">{{instructions}}</textarea>
    <input type="text" name="time" placeholder="Time needed (e.g. 30mins)…" value="{{time}}">
  {{/composer}}
</li>
```

The admin UI will look like this:

![Rendered composer helper](composer-helper.png?raw=true)

And the stored data will be like this:

```ruby
slice.ingredients # =>
[
  {
    name: "Cheese",
    amount: "10kg"
  },
  {
    name: "Eggs",
    amount: "5"
  }
]
slice.steps # =>
[
  {
    title: "Grate Cheese",
    instructions: "Grate the cheese into a bowl…",
    time: "5 mins"
  },
  {
    title: "Cook Eggs",
    instructions: "Crack eggs intro frying pan…",
    time: "15 mins"
  }
]
```

For more complex content, you can use embedded documents:

```ruby
  class Ingredient
    include Mongoid::Document
    field :name
    field :amount

    def in_season?
      # …
    end

    embedded_in :slice, class_name: "RecipeSlice"
  end
  embeds_many :ingredients, class_name: "RecipeSlice::Ingredient"
```
