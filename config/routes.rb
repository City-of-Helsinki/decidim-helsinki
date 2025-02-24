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
    namespace :geocoding do
      get :autocomplete
    end

    get :consent, to: "consent#show", format: :html
  end

  resources :posts, only: [:index, :show], controller: "decidim/blogs/directory/posts", format: :html
  resources :events, only: [:index], controller: "helsinki/linked_events", format: :html

  mount Decidim::Core::Engine => "/"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
