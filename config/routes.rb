Edison::Engine.routes.draw do

	resources 	:experiment_admin
	resources 	:experiment_url_pattern_admin
	resources	:variant_admin
	
end
