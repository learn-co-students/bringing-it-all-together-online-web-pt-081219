class Dog

	 attr_accessor :id, :name, :breed

	 def initialize(attributes)
	 	# attributes = { :id => 1, :name = "BOb", :breed = "lab" }
	 	# k = :breed "#{k}=" => "breed="
	 	# v = "lab"
	 	# self.breed = lab
	 	attributes.each {|k,v| self.public_send("#{k}=",v)}
	 	@id ||=nil
	 end

	def self.create_table
	 		sql = <<-SQL
	 			CREATE TABLE IF NOT EXISTS dogs(
	 				id INTEGER PRIMARY KEY,
					name TEXT,
					breed TEXT
	 			)
	 			SQL

	 		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE dogs")
	end


	 def save
	 	if self.id
	 	   self.update
  		else
	 		DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", name, breed)
	 		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
	 	end
	 	self
	 end


	def update
	    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
	    DB[:conn].execute(sql, name, breed, id)
    end

    def self.create(attributes)
    	d = self.new(attributes)
    	d.save
    end

    def self.new_from_db(row)
    	
    	attributes = {:id => row[0], :name => row[1], :breed => row[2]}
    	self.new(attributes)
    end

    def self.find_by_id(id)
    	sql = <<-SQL
    			SELECT * FROM dogs 
    			WHERE id = ?
    		  SQL

    	DB[:conn].execute(sql, id).map do |row|
    		self.new_from_db(row)
    	end.first
    end

    def self.find_or_create_by(name:, breed:) 
    	dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    	attributes = {}
    	if !dog.empty?	
    		dog_data = dog[0]
    		attributes[:id] = dog[0][0]
    		attributes[:name] = dog[0][1]
    		attributes[:breed] = dog[0][2]
    		dog = self.new(attributes)
    	else
    		attributes[:name] = name
    		attributes[:breed] = breed
    		dog = self.create(attributes)
   		end
   		dog

   end

   def self.find_by_name(name)
		sql = <<-SQL
		SELECT * FROM dogs 
		WHERE name = ?
	  SQL

    	DB[:conn].execute(sql, name).map do |row|
    		self.new_from_db(row)
    	end.first
    end
end
