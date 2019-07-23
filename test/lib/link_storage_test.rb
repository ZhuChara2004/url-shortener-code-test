# frozen_string_literal: true

require File.expand_path '../test_helper', __dir__

class LinkStorageTest < Minitest::Test
  STORAGE_FILE_NAME = "#{ENV['RACK_ENV']}_url_store.pstore"
  URL = 'http://www.google.com'

  def test_save_value
    clear_storage
    shortened_url = store.send('shorten_url', URL)

    assert store_items_count.zero?

    assert store.save_value(URL) == shortened_url
    assert store_items_count == 1
  end

  def test_read_value
    shortened_url = store.save_value(URL)

    assert store.read_value(shortened_url) == URL
  end

  def test_index
    clear_storage
    store.save_value(URL)
    store.save_value('facebook.com')

    result = store.index

    assert result.length == 2
    assert result.keys.include?('http://facebook.com')
  end

  private

  def store
    LinkStorage.new(STORAGE_FILE_NAME)
  end

  def store_items_count
    pstore = PStore.new(STORAGE_FILE_NAME)
    pstore.transaction { pstore.roots }.count
  end

  def clear_storage
    pstore = PStore.new(STORAGE_FILE_NAME)
    pstore.transaction { pstore.roots.each { |r| pstore.delete(r) } }
  end
end
