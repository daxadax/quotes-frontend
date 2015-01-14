module Helpers
  module RouteHelpers

    def quote_path(uid)
      "/quote/#{uid}"
    end

    def kindle_import_path
      "/quotes/import_from_kindle"
    end

    def edit_quote_path(uid)
      "/edit_quote/#{uid}"
    end

    def delete_quote_path(uid)
      "/delete_quote/#{uid}"
    end

    def similar_quotes_path(uid)
      "/similar_quotes/#{uid}"
    end

    def user_profile_path(uid = nil)
      uid ||= current_user.uid

      "/user/#{uid}"
    end

    def user_quotes_path(uid, limit = nil)
      limit = "?limit=#{limit}" if limit

      "/user/#{uid}/added/quotes" + limit.to_s
    end

    def favorite_quotes_path(uid, limit = nil)
      limit = "?limit=#{limit}" if limit

      "/user/#{uid}/favorites" + limit.to_s
    end

    def user_tags_path(uid, limit = nil)
      limit = "?limit=#{limit}" if limit

      "/user/#{uid}/tags" + limit.to_s
    end

  end
end
