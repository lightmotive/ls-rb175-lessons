# frozen_string_literal: true

require 'uri'
require './url_utils'

# App-level helper methods
module CMSAppHelper
  APP_ROUTES = {
    logout: '/logout',
    index: '/',
    login: '/users/login',
    view: '/view',
    edit: '/edit',
    delete: '/delete',
    browse: '/browse',
    new_dir: '/new/dir',
    new_file: '/new/file'
  }.freeze

  def self.location_query_param(loc)
    loc = nil if loc == '/'
    return {} if loc.nil? || loc.empty?

    loc = "/#{loc}" unless loc.start_with?('/')
    { loc: }
  end

  def self.app_route(route, path: '', loc: nil, other_query_params: {})
    route = APP_ROUTES[route]

    query_params = location_query_param(loc).merge(other_query_params)
    query_string = if query_params.empty?
                     ''
                   else
                     "?#{URI.encode_www_form(query_params)}"
                   end

    "#{URLUtils.join_components(route, path)}#{query_string}"
  end

  # Define routes available to unauthenticated users
  PUBLIC_ROUTES = [
    app_route(:index),
    app_route(:login),
    app_route(:logout)
  ].freeze

  # Get a standardized app route path
  def app_route(route, path: '', loc: nil, other_query_params: {})
    CMSAppHelper.app_route(
      route, path:, loc:, other_query_params:
    )
  end

  # Current request's Rack App-mapped route
  def request_script_name_standardized
    name = request.script_name
    name.empty? ? '/' : name
  end

  # Check whether a specific route is available to unauthenticated users
  def route_public?(route)
    PUBLIC_ROUTES.include?(route)
  end
end
