Shapado::Application.configure do
  config.cache_classes                     = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets               = true
  config.action_mailer.delivery_method     = :smtp
  config.active_support.deprecation        = :notify

  config.after_initialize do
    Topic.handle_asynchronously :remove_from_suggestions
  end
end

class ActionDispatch::Request
  def local?
    false
  end
end
