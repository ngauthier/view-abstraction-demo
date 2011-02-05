require 'test_helper'

class PostTest < ActionDispatch::IntegrationTest
  test 'make a blog post' do
    # Given I am on the posts page
    visit posts_path
    # When I create a new post
    click_link 'New Post'
    View::Post.create(
      :title => 'View abstraction in integration tests',
      :body => 'We must go deeper'
    )
    # Then I should see a success message
    assert_see 'Successfully created post.'

    # When I visit the posts index
    visit posts_path
    # Then I should see one post
    assert_equal 1, View::Post.all.size
    # And it should have the correct title
    assert_equal 'View abstraction in integration tests', View::Post.all.first.title
    # And it should have the correct body
    assert_equal 'We must go deeper', View::Post.all.first.body
  end

  test 'delete a blog post' do
    # Given I made two blog posts
    2.times do |i|
      visit posts_path
      click_link 'New Post'
      View::Post.create(
        :title => "Post #{i}",
        :body => "Body for #{i}"
      )
    end
    # When I go to the posts path
    visit posts_path
    # Then I should see two posts
    assert_equal 2, View::Post.all.size
    # When I delete Post 0
    View::Post.find_by_title('Post 0').delete
    # Then I should see one post
    assert_equal 1, View::Post.all.size
    # And I should not see Post 0
    assert_nil View::Post.find_by_title('Post 0')
    # And I should see Post 1
    refute_nil View::Post.find_by_title('Post 1')
  end

  test 'edit a blog post' do
    # Given I made a blog post
    visit posts_path
    click_link 'New Post'
    View::Post.create(
      :title => "Original Title",
      :body => "Original Body"
    )
    # When I edit the post
    View::Post.find_by_title('Original Title').edit(
      :title => "New Title",
      :body => "New Body"
    )
    # And I go to the posts page
    visit posts_path
    # Then it should have the new title
    post = View::Post.all.first
    refute_nil post
    assert_equal "New Title", post.title
    # And it should have the new body
    assert_equal "New Body", post.body
  end

  test 'view a blog post' do
    # Given I made a blog post
    visit posts_path
    click_link 'New Post'
    View::Post.create(
      :title => "My Title",
      :body => "My Body"
    )
    # When I visit the posts path
    visit posts_path
    # and I view the post
    View::Post.all.first.view
    # Then I should see the post
    post = View::Post.find_by_title('My Title')
    refute_nil post
    # And it should have the correct body
    assert_equal 'My Title', post.title
    # And it should have the correct title
    assert_equal 'My Body', post.body
  end

  test 'sort by date descending' do
    # Given I make a post 
    visit posts_path
    click_link 'New Post'
    View::Post.create(
      :title => "Old Post",
      :body => "from yesterday"
    )
    # And wait a second
    sleep(1) # yeah I put sleep in a test, wanna fight?
    # And I make another post
    visit posts_path
    click_link 'New Post'
    View::Post.create(
      :title => "Current Post",
      :body => "from today"
    )
    # When I view the posts page
    visit posts_path
    # Then the one from today should be first
    assert_equal 'Current Post', View::Post.all.first.title
    # And the one from yesterday should be second
    assert_equal 'Old Post', View::Post.all.second.title
  end
end
