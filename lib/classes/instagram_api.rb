require "instagram"

class NnApi::InstagramApi
	include Instagram

	def initialize
		Instagram.configure do |config|
		  config.client_id = "f8c5b8d1064043fb8486cd18b9c2c238"
		  config.access_token = "cfe588db9f57411f95a13e615f602049"
		end
	end

	def get_media_nearby
		return Instagram.media_search("51.5248","-0.133427", { 
			:client_id => "f8c5b8d1064043fb8486cd18b9c2c238",
			:distance => 100 })
	end
end