require "tanga_namespaced_helpers/version"
require 'request_store'

module Rooster
  def self.view_context
    RequestStore.store[:view_context]
  end

  def self.view_context= context
    RequestStore.store[:view_context] = context
  end

  # Workaround for ActionMMailer apparently resetting some of the view context sometimes.
  def self.original_view_context
    RequestStore.store[:original_view_context]
  end

  def self.original_view_context= context
    RequestStore.store[:original_view_context] = context
  end
end

# This probably isn't the best way to structure the code.
# Stupid name, bad code, no tests, etc.
module TangaNamespacedHelpers
  def self.reset! controller
    view_context = controller.view_context

    # Hack to get Haml helpers available
    if defined? Haml
      class << view_context
        include Haml::Helpers
      end
      view_context.init_haml_helpers
    end
    Rooster.view_context = view_context

    if controller.is_a?(ActionController::Base)
      Rooster.original_view_context = view_context
    end

  end

  def self.use_controller!
    if Rooster.original_view_context
      Rooster.view_context = Rooster.original_view_context
    end
  end

  def view
    Rooster.view_context
  end

  def method_missing *args, &block
    view.send *args, &block
  rescue NoMethodError
    # This is pretty stupid.  ActionMailer sometimes resets the current view context.
    # So, if there's a NoMethodError (i.e. access the session after ActionMailer
    # resets the context), we need to reset it to the original controller
    # for the request and try one more time.
    if TangaNamespacedHelpers.use_controller!
      view.send *args, &block
    else
      raise
    end
  end

  module ControllerMethods
    def self.included base
      base.before_filter :reset_namespace_view_context
    end

    def reset_namespace_view_context
      TangaNamespacedHelpers.reset!(self)
    end
  end
end

ActionController::Base.send :include, TangaNamespacedHelpers::ControllerMethods

class ActionMailer::Base
  # This is necessary to use namespaced helpers from the actionmailer views
  default 'init-view' => Proc.new { TangaNamespacedHelpers.reset!(self) }
end

