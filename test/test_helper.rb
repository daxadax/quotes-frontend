ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = 'mysql2://dax:dax@localhost/quotes_test'

require 'sinatra'
require 'bundler'
Bundler.require

require 'rack/test'
Dir.glob('./helpers/*.rb') { |f| require f }
require './quotes_app'
require 'minitest/autorun'
require 'capybara'
require 'capybara/dsl'

enable :sessions
Capybara.app = QuotesApp
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end

class QuotesAppTest < Minitest::Spec
  include Capybara::DSL

  before do
    clean_database
    app.views = './views'
    @user = create_user
    @publication = create_publication(@user)
    @quote = create_quote(@user, @publication)
    page.driver.post('/login', { :nickname => "test user", :password => 'auth' })
  end

  def app
    Capybara.app
  end

  def assert_successful_loading_of(route)
    failure_msg = "Unexpected response for #{page.current_url}"

    visit route
    assert_equal 200, page.status_code, failure_msg
  end

  def login(nickname, auth_key)
    Manager::Interface.authenticate_user(
      :nickname => nickname,
      :auth_key => auth_key,
      :login_data => {
        :ip_address => 'test ip'
      }
    )
  end

  def create_user
    Manager::Interface.create_user(
      :nickname => 'test user',
      :email => 'no email added',
      :auth_key => 'test userauth'
    )
  end

  def create_publication(user)
    Manager::Interface.create_publication(
      :user_uid => user.uid,
      :publication => {
        :author => 'author',
        :title => 'title',
        :publisher => 'publisher',
        :year => 1999
      }
    )
  end

  def create_quote(user, publication)
    Manager::Interface.create_quote(
      :user_uid => user.uid,
      :quote => {
        :content => 'Lorem ipsum...',
        :publication_uid => publication.uid,
        :page_number => 93,
        :tags => ['some', 'tags'],
        :links => []
      }
    )
  end

  private

  def clean_database
    existing_tables = database.tables
    tables_to_preserve = [:schema_info, :schema_migrations]
    tables_to_be_emptied  = existing_tables - tables_to_preserve

    tables_to_be_emptied.each { |table| database << "TRUNCATE #{table}" }
  end

  def database
    @database ||= Sequel.connect(ENV.fetch("DATABASE_URL"))
  end

  def migration_directory
    "../persistence/migrations/"
  end
end
