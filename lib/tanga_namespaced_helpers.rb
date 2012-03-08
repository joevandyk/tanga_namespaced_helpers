require "tanga_namespaced_helpers/version"

# This probably isn't the best way to structure the code.
# Stupid name, bad code, no tests, etc.
module TangaNamespacedHelpers
  def self.reset! controller
    @view = controller.view_context
    if controller.is_a?(ActionController::Base)
      @controller = controller
    end

    # Hack to get Haml helpers available
    if defined? Haml
      class << @view
        include Haml::Helpers
      end
      @view.init_haml_helpers
    end
  end

  def self.view
    @view
  end

  def self.controller
    @controller
  end

  # TODO Gotta be a better way to do this.
  def view
    TangaNamespacedHelpers.view
  end

  def controller
    TangaNamespacedHelpers.controller
  end

  def method_missing *args, &block
    retry_count ||= 0
    view.send *args, &block
  rescue NoMethodError
    # This is pretty stupid.  ActionMailer sometimes resets the current view context.
    # So, if there's a NoMethodError (i.e. access the session after ActionMailer
    # resets the context), we need to reset it to the original controller
    # for the request and try one more time.
    if retry_count == 0
      TangaNamespacedHelpers.reset!(controller)
      retry_count += 1
      retry
    else
      raise
    end
  end

  module ControllerMethods
    def self.included base
      base.before_filter :reset_namespace_view_context
    end

    def reset_namespace_view_context
      TangaNamespacedHelpers.reset! self
    end
  end
end


ActionController::Base.send :include, TangaNamespacedHelpers::ControllerMethods

class ActionMailer::Base
  # This is necessary to use namespaced helpers from the actionmailer views
  default 'init-view' => Proc.new { TangaNamespacedHelpers.reset!(self) }
end
