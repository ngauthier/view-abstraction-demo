ViewAbstractionDemo::Application.routes.draw do
  resources :posts
  match '/' => redirect('/posts')
end
