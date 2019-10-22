class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    self.name = name
    self.breed = breed
    @id = id
  end

  def self.create_table
    sql = <<~SQL
        CREATE TABLE IF NOT EXISTS dogs (
               id INTEGER PRIMARY KEY,
               name TEXT,
               breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<~SQL
        DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<~SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, name, breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]

    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<~SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL

    row = DB[:conn].execute(sql, id).first

    new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<~SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL

    row = DB[:conn].execute(sql, name, breed).first

    if row
      new_from_db(row)
    else
      Dog.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = <<~SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    row = DB[:conn].execute(sql, name).first

    new_from_db(row)
  end

  def update
    sql = <<~SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end
end
