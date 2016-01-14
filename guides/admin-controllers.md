# Admin Controllers

Custom admin controllers should subclass `Admin::AdminController`:

```ruby
# app/controllers/admin/foos_controller.rb
class Admin::FoosController < Admin::AdminController
  # ...
end
```

Add routes within the `admin` namespace:

```ruby
# config/routes.rb
Foo::Application.routes.draw do
  namespace :admin do
    resources :foos
  end
end
```
