# frozen_string_literal: true

# Remove after the comments refactor is merged to the core.
Decidim::Comments::Engine.routes.prepend do
  resources :comments, only: [:index, :create] do
    resources :votes, only: [:create]
  end
end

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  mount Decidim::Comments::Engine, at: "/", as: "decidim_comments"

  scope module: "helsinki" do
    devise_scope :user do
      # Manually map the Tunnistamo omniauth callback route for Devise because
      # the default routes are mounted by core Decidim. This is because we want
      # to map this route to the local callbacks controller instead of the
      # Decidim core to add extra functionality.
      # See: https://git.io/fjDz1
      match(
        "/users/auth/tunnistamo/callback",
        to: "omniauth_callbacks#tunnistamo",
        as: "user_tunnistamo_omniauth_callback",
        via: [:get, :post]
      )
    end

    namespace :geocoding do
      get :autocomplete
    end
  end

  resources :posts, only: [:index, :show], controller: "decidim/blogs/directory/posts", format: :html

  mount Decidim::Core::Engine => "/"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
