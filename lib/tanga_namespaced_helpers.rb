require "tanga_namespaced_helpers/version"

# This probably isn't the best way to structure the code.
# Stupid name, bad code, no tests, etc.
module TangaNamespacedHelpers
  def self.reset! controller
    @view = controller.view_context
  end

  def self.view
    @view
  end

  # TODO Gotta be a better way to do this.
  def view
    TangaNamespacedHelpers.view
  end

  def method_missing *args, &block
    view.send *args, &block
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
