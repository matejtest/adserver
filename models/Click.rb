class Click

	include DataMapper::Resource

	property :id, Serial
	property :ip_address, String
	property :created_at, DateTime

	belongs_to :ad

end