class FacebookPlace
  include Mongoid::Document
  include Mongoid::FullTextSearch
  # include Mongoid::Slug
  include Mongoid::Timestamps # adds automagic fields created_at, updated_at

  has_and_belongs_to_many :followers, class_name: "User", inverse_of: :following_places

  # before_save :update_index
  before_destroy :remove_from_index

  field :name, :type => String
  field :facebook_id, :type => Integer
  field :location, :type => Hash

  paginates_per 25

  fulltext_search_in :name, :index_name => 'mongoid_fulltext.name'

  def self.find_by_facebook_id(fb_id) 
    where(:facebook_id => fb_id).first
  end

  def self.get_by_hash(hash)
    @place = FacebookPlace.new(
      :facebook_id  => hash["id"],
      :name         => hash["name"],
      :category     => hash["category"],
      :location     => hash["location"])

    @find_place = FacebookPlace.where(:facebook_id => @place.facebook_id).first
    
    unless @find_place.nil?
      p "Saving new Facebook place.."
      @place = @find_place
    else
      @place.save
    end

    @place
  end

  # Mongoid does not have the dynamic finders that active record does
  def self.find_by_name(current_user, name)
    @graph = Koala::Facebook::API.new(current_user.token)
    
    p "Searching Facebook place: "+name
    @results = @graph.search(name, {:type => "place"})
    
    @places = []
    @results.each do |hash|
      @place = FacebookPlace.get_by_hash(hash)
      @places.push(@place)
    end
    @places
  end

  def update_index
    FacebookPlace.update_ngram_index
  end

  def remove_from_index
    FacebookPlace.remove_from_ngram_index
  end

  def self.search_by_name(name)
    update_index
    fulltext_search(name, :index => 'mongoid_fulltext.name')
  end

  def latitude
    unless self.location.empty?
      return self.location["latitude"]
    end
  end

  def longitude
    unless self.location.empty?
  	 return self.location["longitude"]
    end
  end

  def followBy(user)
    self.followers.push(user)
    self.save
  end

  def unfollowBy(user)
    self.followers.delete(user)
    self.save
  end

  def isFollowedBy(user)
    if self.followers.exists? && self.followers.find(user.id)
      true
    else
      false
    end
  end
end
