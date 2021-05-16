Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :results, only: %i[index] do
    collection { post 'show_result', to: 'results#show_result', as: :show }
    collection { get 'verify_result', to: 'results#verify_result' , as: :verify}
  end
end
