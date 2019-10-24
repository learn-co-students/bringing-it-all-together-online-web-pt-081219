class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs;
        SQL

        DB[:conn].execute(sql)
    end

    def self.create(hash)
        new_dog = Dog.new(
            name: hash[:name],
            breed: hash[:breed]
        )
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
         new_dog = Dog.new(
            name: row[1],
            breed: row[2]
        )
        new_dog.id = row[0]
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE dogs.id = ?
            LIMIT 1;
        SQL

        result = DB[:conn].execute(sql, id)[0]
        new_from_db(result)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
        SQL

        result = DB[:conn].execute(sql, name, breed)
        
        if !result.empty?
            #return the obj
            self.new_from_db(result[0])
        else
            #create the obj
            self.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1;
        SQL
        
        result = DB[:conn].execute(sql, name)[0]
        self.new_from_db(result)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed) VALUES (?, ?);
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        end
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE dogs.id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end