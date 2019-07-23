require 'pstore'

class LinkStorage
  def initialize(store_name = 'url_store.pstore')
    @store = client(store_name)
  end

  def index
    Hash[
      @store.transaction do
        @store.roots.map { |r| [@store.fetch(r), r] }
      end
    ]
  end

  def read_value(shortened_url)
    begin @store.transaction { @store.fetch(shortened_url) }
    rescue PStore::Error
      ''
    end
  end

  def save_value(url)
    valid_url = validate_url(url)
    shortened_url = shorten_url(valid_url)
    @store.transaction { @store[shortened_url] = valid_url }
    shortened_url
  end

  private

  def client(store_name)
    PStore.new(store_name)
  end

  def validate_url(url)
    URI.parse(url).scheme ? url : "http://#{url}"
  end

  def shorten_url(url)
    Digest::MD5.hexdigest(url).slice(0..7)
  end
end
