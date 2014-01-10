require 'spec_helper'

describe ActiveSupport::Cache::FileStore do

  before do
    Dir.mkdir(cache_dir) unless File.exist?(cache_dir)
  end

  let :cache do
    ActiveSupport::Cache.lookup_store(:file_store, cache_dir, expires_in: 60)
  end

  let :peed do
    ActiveSupport::Cache.lookup_store(:file_store, cache_dir, expires_in: 60)
  end

  after do
    FileUtils.rm_r(cache_dir)
  end

  let :cache_dir do
    File.join(Dir.pwd, 'tmp_cache')
  end

  context "delection matched with url regular expression" do
    before do
      cache.write('localhost/blog/1?page=1', 'article 1,2,3,4,5')
      cache.write('localhost/blog/1?page=2', 'article 6,7,8,9')
    end

    it "reads from the cache" do
      cache.read('localhost/blog/1?page=1').should eq 'article 1,2,3,4,5'
      cache.read('localhost/blog/1?page=2').should eq 'article 6,7,8,9'
    end

    it "deletes from the cache" do
      cache.delete_matched(/^localhost\/blog\/1/)
      cache.read('localhost/blog/1?page=1').should be_nil
      cache.read('localhost/blog/1?page=2').should be_nil
    end
  end

  it "depreacates expires in on read" do
    pending
    ActiveSupport::Deprecation.silence do
      old_cache = ActiveSupport::Cache.lookup_store(:file_store, cache_dir)

      time = Time.local(2008, 4, 24)
      Time.stub(:now).and_return(time)

      old_cache.write("foo", "bar")
      old_cache.read('foo', expires_in: 60).should eq 'bar'

      Time.stub(:now).and_return(time + 30)
      old_cache.read('foo', expires_in: 60).should eq 'bar'

      Time.stub(:now).and_return(time + 61)
      old_cache.read('foo').should eq 'bar'
      old_cache.read('foo', expires_in: 60).should be_nil
      old_cache.read('foo').should be_nil
    end
  end

  it "transforms keys" do
    key = cache.send(:key_file_path, "views/index?id=1")
    cache.send(:file_path_key, key).should eq "views/index?id=1"
  end
end


