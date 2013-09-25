require "sidekiq/web"

Touchbase::Application.routes.draw do
  
  namespace :api, defaults: { format: :json } do
    scope module: :v1 do
      resources :contacts
    end
  end
  
  devise_for :users
  
  unauthenticated :user do
    devise_scope :user do
      get "/checklist" => "devise/registrations#new"
      root "websites#new"
    end
  end
  
  constraints subdomain: "www" do
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
        resources :documents, path: :files
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
  end
  
  constraints subdomain: /.+/ do
    authenticated :user do
      resources :websites do
        post "/save" => "websites#save", as: :save
        
        resources :pages
        resources :documents, path: :files
      end
    end
    
    get "/:permalink" => "pages#show", as: :public_page
    get "/" => "pages#show"
  end
end
