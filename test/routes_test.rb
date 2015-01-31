require 'test_helper'

class RoutesTest < QuotesAppTest
  # order is important!
  let(:routes_tested) do
    [
      '/',
      '/random',
      '/login',
      '/user/new',
      "/user/#{@user.uid}",
      "/user/#{@user.uid}/added/quotes",
      "/user/#{@user.uid}/favorites",
      "/user/#{@user.uid}/tags",
      "/publication/#{@publication.uid}",
      '/publication/new',
      "/publication/edit/#{@publication.uid}",
      '/quotes',
      "/quote/#{@quote.uid}",
      '/import_from_kindle',
      '/quote/new',
      "/edit_quote/#{@quote.uid}",
      "/similar_quotes/#{@quote.uid}",
      '/tags',
      "/tag/tag",
      '/authors',
      "/author/author",
      "/toggle_star/#{@quote.uid}",
      "/delete_quote/#{@quote.uid}",
      '/logout'
    ]
  end

  before do
    @publication = create_publication(@user)
    @quote = create_quote(@user, @publication)
  end

  it "tests all the 'get' routes" do
    number_of_routes = app.routes["GET"].size

    assert_equal number_of_routes, routes_tested.size,
    routes_tested.each { |route| assert_successful_loading_of route }
  end

end
