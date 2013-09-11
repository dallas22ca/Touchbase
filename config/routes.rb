require "sidekiq/web"

Touchbase::Application.routes.draw do
  
  namespace :api, defaults: { format: :json } do
    scope module: :v1 do
      resources :contacts
    end
  end

  constraints subdomain: "www" do
    devise_for :users
  
    get "/s/:token" => "contacts#subscriptions", as: :subscription
  
    authenticated :user do
      get "/pending" => "contacts#pending", as: :pending
      post "/multicreate" => "contacts#multicreate", as: :multicreate_contacts
    
      resources :tasks
      resources :users
      resources :followups, path: :templates
      resources :emails
      resources :websites do
        resources :pages, except: :show
      end
    
      resources :contacts do 
        resources :notes
      end
    
      get "/fields" => "fields#index", as: :fields
      patch "/fields" => "fields#update"

      mount Sidekiq::Web => "/sidekiq"
    
      get "/" => "tb_pages#show"
    end

    post "/:permalink/submit" => "tb_pages#submit", as: :submit
    get "/:permalink/:option" => "tb_pages#option", as: :option
    get "/:permalink" => "tb_pages#show", as: :tb_page
  
    unauthenticated :user do
      devise_scope :user do
        root "devise/registrations#new"
      end
    end
  end
  
  constraints subdomain: /.+/ do
    get "/:permalink" => "pages#show"
    get "/" => "pages#show"
  end
end
