Rails.application.routes.draw do
  mount Edison::Engine => "/edison"
end
