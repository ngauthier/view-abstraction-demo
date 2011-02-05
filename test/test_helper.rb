ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/dsl'
require 'uri'

Capybara.app = ViewAbstractionDemo::Application
Capybara.default_selector = :css
Capybara.default_driver = :akephalos

class ActiveSupport::TestCase
end

class ActionDispatch::IntegrationTest
  # Use capybara
  include Capybara

  # Instead of transactions, use truncation
  self.use_transactional_fixtures = false

  # Cleanup db via truncation and clean sessions
  setup do
    Capybara.reset_sessions!
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end
  teardown do
    DatabaseCleaner.clean
  end

  # Helpful base assertions
  def assert_see(content, msg = nil)
    assert page.has_content?(content), (msg || %{Expected to see #{content}})
  end
  def refute_see(content, msg = nil)
    assert !page.has_content?(content), (msg || %{Did not expect to see #{content}})
  end

  module View
    def self.body
      Nokogiri::HTML(Capybara.current_session.body)
    end

    class Abstract
      # Access capybara dsl in the view helper classes too
      include Capybara
      extend  Capybara

      def initialize(node)
        @id = node['id']
      end
      def self.all
        nodes.map{|node| new(node) }
      end
      private
      def id
        %{##{@id}}
      end
    end

    class Post < View::Abstract
      attr_reader :title
      attr_reader :body
      def initialize(node)
        super
        @title = node.css('.title').first.text.strip
        @body = node.css('.body').first.text.strip
      end

      def self.find_by_title(title)
        all.detect{ |node| node.title == title }
      end

      def self.create(opts = Hash.new(''))
        fill_form opts
        click_button 'Create Post'
      end

      def edit(opts = Hash.new(''))
        within(id) { click_link 'Edit' }
        fill_form opts
        click_button 'Update Post'
      end

      def delete
        within(id) { click_button 'Delete' }
      end

      def view
        within(id) { click_link title }
      end

      private
      def self.nodes
        View.body.css('.post')
      end

      def self.fill_form(opts)
        fill_in 'Title', :with => opts[:title]
        fill_in 'Body', :with => opts[:body]
      end
      def fill_form(opts); self.class.fill_form(opts); end
    end
  end
end
