require 'test_helper'

class RoutesTest < QuotesAppTest
  let(:routes_tested) do
    [
      '/',
      '/random',
      '/login',
      '/user/new',
      "/user/#{@user.uid}",
      "/user/#{@user.uid}/added/quotes",
      "/user/#{@user.uid}/untagged",
      "/user/#{@user.uid}/favorites",
      "/user/#{@user.uid}/tags",
      "/publication/#{@publication.uid}",
      '/publication/new',
      "/publication/edit/#{@publication.uid}",
      '/quotes',
      "/quote/#{@quote.uid}",
      '/quote/new',
      "/edit_quote/#{@quote.uid}",
      "/delete_quote/#{@quote.uid}",
      "/similar_quote/#{@quote.uid}",
      '/tags',
      "/tag/tag",
      '/authors',
      "/author/author",
      "/toggle_star/#{@quote.uid}",
      '/logout'
    ]
  end

  it "tests all the 'get' routes" do
    number_of_routes = app.routes["GET"].size

    assert_equal number_of_routes, routes_tested.size,
    routes_tested.each { |route| assert_successful_loading_of route }
  end

end
