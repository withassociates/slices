# Deploy to Heroku

**Note: Slices sites cannot currently be deployed on Heroku's free tier.**

Running a Slices app on Heroku requires a few things: an Amazon S3 bucket, a
Mongo database, a Github repository and a Heroku app.

Make sure when you run `rails g slices:install --heroku` when you install
Slices into your app.

## Heroku

Create a free [Heroku](http://www.heroku.com) account and install the
[Heroku Toolbelt](https://toolbelt.heroku.com/).

If you haven't already, create a [Github](http://www.github.com) account. Once
you have an account, you can [create a repository](https://github.com/new) for
your project by following the instructions.

Once you've committed your Slices site to Github, we'll need to create a Heroku
app for the site to reside in:

```sh
$ heroku create mywebsite
```

## Amazon S3

Add these gems to your `Gemfile`, then run `bundle install`:

```ruby
gem 'fog'
gem 'paperclip'
gem 'asset_sync', group: :assets
```

We'll need an S3 bucket to store the assets. Visit the
[S3 Console](https://console.aws.amazon.com/s3/home?region=us-east-1)
and click "Actions > Create Bucket..."

Next, edit the CORS configuration. Select the newly-created bucket and click
"Properties > Permissions > Add CORS Configuration". Paste the following XML
into the text area:

```xml
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
  </CORSRule>
</CORSConfiguration>
```

Create a user at the [IAM Management Console](https://console.aws.amazon.com/iam/home?#s=Users).
Be sure to make a note of your Access Key ID and Secret Access Key - we'll need them later!

Finally, we'll make sure to give the user permission to upload assets to the
bucket. Click your bucket's name in the table, click the "Permissions" tab,
then "Attach User Policy > Custom Policy > Select" and paste the following into
the text area, replacing "YOUR-BUCKET-NAME" with the bucket name you clicked on
in the table:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::YOUR-BUCKET-NAME",
        "arn:aws:s3:::YOUR-BUCKET-NAME/*"
      ]
    }
  ]
}
```

## Paperclip and Fog

Next, we need to configure Paperclip, which handles assets, to use Fog and
Rails to work with the Amazon S3 bucket. Add the following to
`config/environments/production.rb`:

```ruby
# Serve assets from S3 bucket
config.action_controller.asset_host = "//#{ENV['AWS_BUCKET']}.s3.amazonaws.com"

# Amazon S3 settings for Paperclip uploads
config.paperclip_defaults = {
  storage: :fog,
  fog_directory: ENV["AWS_BUCKET"],
  fog_public: true,
  fog_credentials: {
    provider: "AWS",
    aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
  }
}
```

Now we add the Amazon S3 and Asset Sync configuration to Heroku via the
terminal. This means our secret key data is not visible to anyone on Github.
Again, be sure to replace 'YOUR-BUCKET-NAME' with the name of your bucket, and
the other data with the keys we noted down earlier:

```sh
$ heroku config:set AWS_ACCESS_KEY_ID="your_key" \
                    AWS_SECRET_ACCESS_KEY="your_secret" \
                    AWS_BUCKET="YOUR-BUCKET-NAME" \
                    FOG_DIRECTORY="YOUR-BUCKET-NAME" \
                    FOG_PROVIDER="AWS"
```

## Mongo

By default, Heroku apps use Postgres databases, while Slices uses a Mongo
database. To get our app up and running, we need to configure Heroku slightly
to reflect this, by adding the MongoLab add-on. Please note that Slices
requires a paid tier of MongoLab, coming in at at least $18 per month. Run this
command:

```sh
$ heroku addons:create mongolab:shared-cluster-1
```

And add this code to `config/mongoid.yml`:

```yml
production:
  uri: <%= ENV["MONGOLAB_URI"] %>
```

## Deploying

After all that, we're almost there! All that remains is commit your changes to
Github and deploy the app:

```sh
$ git push heroku master
```

Finally, seed Slices' starting data:

```sh
$ heroku run rake slices:seed
```

Awesome! Run `heroku open` to see your website in all its glory, and visit
`/admin` to start adding content.

## Creating slices/styling your app

Slices are created locally, committed to Github then deployed to Heroku before
they can be used on your live site. The same goes for CSS changes.
See the [Creating Slices guide](creating-slices.md) guide for more.
